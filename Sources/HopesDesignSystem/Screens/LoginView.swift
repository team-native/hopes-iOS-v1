import SwiftUI
import UIKit

public struct LoginView: View {
    private enum LoginField: Hashable {
        case email
        case password
    }

    private struct FieldFramePreferenceKey: PreferenceKey {
        static let defaultValue: [LoginField: CGRect] = [:]

        static func reduce(
            value: inout [LoginField: CGRect],
            nextValue: () -> [LoginField: CGRect]
        ) {
            value.merge(nextValue(), uniquingKeysWith: { $1 })
        }
    }

    @State private var isPasswordVisible = false
    @State private var sheetProgress: CGFloat
    @State private var sheetDragStartProgress: CGFloat?
    @State private var keyboardShift: CGFloat = 0
    @State private var keyboardFrame: CGRect = .zero
    @State private var fieldFrames: [LoginField: CGRect] = [:]
    @State private var maximumKeyboardShift: CGFloat = 0
    @State private var keyboardAnimationDuration: TimeInterval = 0.25
    @Binding private var email: String
    @Binding private var password: String
    @FocusState private var focusedField: LoginField?

    private let onLogin: () -> Void
    private let onSignUp: () -> Void
    private let onForgotPassword: () -> Void
    private let isLoading: Bool
    private let errorMessage: String?

    public init(
        email: Binding<String>,
        password: Binding<String>,
        isLoading: Bool = false,
        errorMessage: String? = nil,
        isInitiallyExpanded: Bool = false,
        onLogin: @escaping () -> Void = {},
        onSignUp: @escaping () -> Void = {},
        onForgotPassword: @escaping () -> Void = {}
    ) {
        _sheetProgress = State(initialValue: isInitiallyExpanded ? 1 : 0)
        _sheetDragStartProgress = State(initialValue: nil)
        _email = email
        _password = password
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.onLogin = onLogin
        self.onSignUp = onSignUp
        self.onForgotPassword = onForgotPassword
    }

    public var body: some View {
        GeometryReader { geometry in
            let collapsedSheetRevealHeight = min(150, geometry.size.height)
            let collapsedOffset = max(0, 502 - collapsedSheetRevealHeight)
            let sheetOffset = collapsedOffset * (1 - sheetProgress)
            let expandedSheetTop = max(0, geometry.size.height - 502)
            let maximumShiftForSheet = expandedSheetTop * 0.5
            // Designed-for-iPhone compatibility can expose a shorter effective
            // height than a full iPhone screen. Preserve the Figma spacing on
            // regular heights, but make room between the hero copy and cue on
            // compact heights.
            let heroTopPadding = min(168, max(80, geometry.size.height - 615))
            let swipeCueBottomPadding: CGFloat = geometry.size.height < 800 ? 150 : 190
            let keyboardTop = keyboardFrame.height > 0
                ? keyboardFrame.minY
                : geometry.size.height
            let heroBackgroundHeight = keyboardTop
            let currentSheetOffset = sheetOffset - keyboardShift

            ZStack(alignment: .bottom) {
                Color.white
                    .ignoresSafeArea()

                Color.hopesHeroGradient
                    .frame(height: heroBackgroundHeight)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .ignoresSafeArea(edges: .top)

                VStack(spacing: 0) {
                    HopesLogo(placement: .onBrand)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, max(76, geometry.safeAreaInsets.top + 14))
                        .padding(.horizontal, 32)

                    hero
                        .padding(.horizontal, 32)
                        .padding(.top, heroTopPadding)

                    Spacer(minLength: 20)
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                .blur(radius: 5 * sheetProgress)
                .contentShape(Rectangle())
                .onTapGesture { focusedField = nil }

                swipeCue
                    .padding(.bottom, swipeCueBottomPadding)
                    .opacity(1 - sheetProgress)
                    .blur(radius: 5 * sheetProgress)
                    .allowsHitTesting(false)

                loginSheet(maximumKeyboardShift: maximumShiftForSheet)
                    .offset(y: currentSheetOffset)
                    .simultaneousGesture(sheetDragGesture(collapsedOffset: collapsedOffset))

                // When the sheet moves up for the keyboard, its fixed 502pt
                // content no longer reaches the physical bottom of the app
                // window. Keep the same white sheet surface continuous down
                // to that edge so the hero gradient cannot appear between the
                // sheet and the translucent keyboard corners.
                Color.white
                    .frame(height: max(0, -currentSheetOffset))
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    .allowsHitTesting(false)
                    .zIndex(9)

                // The keyboard's rounded bottom area is translucent in the
                // simulator. Cover exactly the keyboard region in the app
                // window so the hero gradient cannot show through it.
                Color.white
                    .frame(
                        height: keyboardFrame.height > 0
                            ? max(0, geometry.size.height - keyboardTop)
                            : 0
                    )
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    .allowsHitTesting(false)
                    .zIndex(10)
            }
            .onAppear {
                maximumKeyboardShift = maximumShiftForSheet
            }
            .onChange(of: geometry.size.height) { _, height in
                maximumKeyboardShift = max(0, height - 502) * 0.5
            }
        }
        .ignoresSafeArea(.container, edges: [.top, .bottom])
        // Keep the fixed Figma sheet geometry stable while the keyboard is
        // visible. Keyboard avoidance is handled explicitly below from the
        // focused field's frame, rather than by shrinking this GeometryReader.
        .ignoresSafeArea(.keyboard)
        .preferredColorScheme(.light)
        .onAppear {
            Task { @MainActor in
                await Task.yield()
                applyLightKeyboardAppearanceToInputs()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { notification in
            guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
            }

            keyboardFrame = frame
            keyboardAnimationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
            Task { @MainActor in
                // Let the focused field's global frame settle after the keyboard layout pass.
                await Task.yield()
                applyLightKeyboardAppearanceToInputs()
                updateKeyboardShift(
                    using: frame,
                    maximumShift: maximumKeyboardShift,
                    animated: true
                )
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { notification in
            keyboardFrame = .zero
            keyboardAnimationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25

            withAnimation(.easeInOut(duration: keyboardAnimationDuration)) {
                keyboardShift = 0
            }
        }
    }

    private func updateKeyboardShift(
        using frame: CGRect,
        maximumShift: CGFloat,
        animated: Bool
    ) {
        guard frame.height > 0,
              focusedField != nil,
              let emailFrame = fieldFrames[.email],
              let passwordFrame = fieldFrames[.password] else {
            return
        }

        // The measured frame already includes the current keyboard translation.
        // Add it back so changing focus does not accumulate or lose the sheet shift.
        // The notification frame is in screen coordinates while the SwiftUI
        // global frame is in the app window's coordinate space. Convert the
        // keyboard frame before comparing the two. Keep both input fields
        // visible; controls below them are intentionally allowed to remain
        // behind the keyboard.
        let keyboardFrameInWindow = keyboardFrameInWindow(frame)
        let unshiftedInputBottom = max(emailFrame.maxY, passwordFrame.maxY) + keyboardShift
        let requiredShift = min(
            maximumShift,
            max(0, unshiftedInputBottom + 14 - keyboardFrameInWindow.minY)
        )

        if animated {
            withAnimation(.easeInOut(duration: keyboardAnimationDuration)) {
                keyboardShift = requiredShift
            }
        } else {
            keyboardShift = requiredShift
        }
    }

    @MainActor
    private func applyLightKeyboardAppearanceToInputs() {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap(\.windows)
            .first(where: { $0.isKeyWindow }),
            let _ = window.windowScene else {
            return
        }

        applyLightKeyboardAppearance(to: window)
    }

    private func applyLightKeyboardAppearance(to view: UIView) {
        if let textField = view as? UITextField,
           textField.keyboardAppearance != .light {
            textField.keyboardAppearance = .light
            if textField.isFirstResponder {
                textField.reloadInputViews()
            }
        } else if let textView = view as? UITextView,
                  textView.keyboardAppearance != .light {
            textView.keyboardAppearance = .light
            if textView.isFirstResponder {
                textView.reloadInputViews()
            }
        }

        for subview in view.subviews {
            applyLightKeyboardAppearance(to: subview)
        }
    }

    private func keyboardFrameInWindow(_ frame: CGRect) -> CGRect {
        #if os(iOS)
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap(\.windows)
            .first(where: { $0.isKeyWindow }) else {
            return frame
        }

        return window.convert(frame, from: window.screen.coordinateSpace)
        #else
        return frame
        #endif
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text("선배에게 묻는\n가장 솔직한\n학교 이야기")
                .font(.system(size: 31, weight: .bold))
                .foregroundStyle(.white)
                .lineSpacing(2)

            Text("재학생, 신입생, 입학 희망자를 위한 AI 선배 챗봇.\n실제 선배들의 경험으로 답해드려요.")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color("HopesHeroSecondary", bundle: .module))
                .lineSpacing(5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var swipeCue: some View {
        VStack(spacing: 0) {
            ZStack {
                Image("SwipeChevronBack", bundle: .module)
                    .resizable()
                    .frame(width: 17, height: 34)
                    .rotationEffect(.degrees(90))
                    .offset(y: -9)

                Image("SwipeChevronFront", bundle: .module)
                    .resizable()
                    .frame(width: 17, height: 34)
                    .rotationEffect(.degrees(90))
                    .offset(y: 9)
            }
            .frame(height: 42)

            Text("위로 스와이프하기")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .padding(.top, 4)

            Text("로그인 창을 올려 학교 이메일로 시작해요.")
                .font(.system(size: 12))
                .foregroundStyle(Color("HopesSwipeHint", bundle: .module))
                .padding(.top, 6)
        }
        .frame(height: 118, alignment: .top)
        .frame(maxWidth: .infinity)
    }

    private func sheetDragGesture(collapsedOffset: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                guard focusedField == nil, collapsedOffset > 0 else { return }

                if sheetDragStartProgress == nil {
                    sheetDragStartProgress = sheetProgress
                }

                let start = sheetDragStartProgress ?? sheetProgress
                let progressDelta = -value.translation.height / collapsedOffset
                sheetProgress = min(1, max(0, start + progressDelta))
            }
            .onEnded { value in
                guard focusedField == nil, collapsedOffset > 0 else {
                    sheetDragStartProgress = nil
                    return
                }

                let start = sheetDragStartProgress ?? sheetProgress
                let projectedProgress = min(
                    1,
                    max(0, start - value.predictedEndTranslation.height / collapsedOffset)
                )
                let targetProgress = projectedProgress > 0.5 ? CGFloat(1) : CGFloat(0)

                sheetDragStartProgress = nil
                withAnimation(.spring(response: 0.48, dampingFraction: 0.9, blendDuration: 0.1)) {
                    sheetProgress = targetProgress
                }
            }
    }

    private func loginSheet(maximumKeyboardShift: CGFloat) -> some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                loginSheetContent
                    .frame(minHeight: 502, alignment: .top)
            }
            .scrollIndicators(.hidden)
            .onPreferenceChange(FieldFramePreferenceKey.self) { frames in
                fieldFrames = frames
            }
            .onChange(of: focusedField) { _, field in
                if field == nil {
                    withAnimation(.easeInOut(duration: keyboardAnimationDuration)) {
                        keyboardShift = 0
                    }
                } else if keyboardFrame.height > 0 {
                    Task { @MainActor in
                        await Task.yield()
                        applyLightKeyboardAppearanceToInputs()
                        updateKeyboardShift(
                            using: keyboardFrame,
                            maximumShift: maximumKeyboardShift,
                            animated: true
                        )
                    }
                }
            }
        }
        .frame(height: 502)
        .background(.white)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 28,
                topTrailingRadius: 28
            )
        )
        .shadow(
            color: Color(red: 13 / 255, green: 26 / 255, blue: 46 / 255).opacity(0.12),
            radius: 16,
            y: 7
        )
    }

    private var loginSheetContent: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color("HopesSheetHandle", bundle: .module))
                .frame(width: 86, height: 5)
                .padding(.top, 20)

            VStack(alignment: .leading, spacing: 0) {
                Text("로그인")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Color.hopesTextPrimary)

                Text("학교 이메일로 로그인하세요.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.hopesTextSecondary)
                    .padding(.top, 4)

                Text("이메일")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.hopesTextPrimary)
                    .padding(.top, 39)

                TextField("이메일", text: $email)
                    .hopesEmailInputTraits()
                    .focused($focusedField, equals: .email)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.hopesTextPrimary)
                    .padding(.horizontal, 16)
                    .frame(height: 40)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(red: 217 / 255, green: 217 / 255, blue: 217 / 255), lineWidth: 1)
                    }
                    .background {
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: FieldFramePreferenceKey.self,
                                value: [.email: geometry.frame(in: .global)]
                            )
                        }
                    }
                    .padding(.top, 7)
                    .accessibilityLabel("이메일")
                    .id(LoginField.email)

                Text("비밀번호")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.hopesTextPrimary)
                    .padding(.top, 15)

                Group {
                    if isPasswordVisible {
                        TextField("비밀번호", text: $password)
                            .focused($focusedField, equals: .password)
                    } else {
                        SecureField("비밀번호", text: $password)
                            .focused($focusedField, equals: .password)
                    }
                }
                    .hopesPasswordInputTraits()
                    .font(.system(size: 15))
                    .foregroundStyle(Color.hopesTextPrimary)
                    .padding(.leading, 16)
                    .padding(.trailing, 42)
                    .frame(height: 40)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(red: 217 / 255, green: 217 / 255, blue: 217 / 255), lineWidth: 1)
                    }
                    .overlay(alignment: .trailing) {
                        Button {
                            isPasswordVisible.toggle()
                        } label: {
                            Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.hopesTextSecondary)
                                .frame(width: 42, height: 40)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(isPasswordVisible ? "비밀번호 숨기기" : "비밀번호 보기")
                    }
                    .background {
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: FieldFramePreferenceKey.self,
                                value: [.password: geometry.frame(in: .global)]
                            )
                        }
                    }
                    .padding(.top, 9)
                    .accessibilityLabel("비밀번호")
                    .id(LoginField.password)

                HStack(spacing: 0) {
                    Spacer()

                    Button {
                        focusedField = nil
                        onForgotPassword()
                    } label: {
                        Text("비밀번호를 잊으셨나요?")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.hopesBrandPrimary)
                    .buttonStyle(.plain)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 32)
            .padding(.top, 43)

            HopesButton(
                isLoading ? "로그인 중..." : "로그인",
                isEnabled: !isLoading && !email.isEmpty && !password.isEmpty,
                action: {
                    focusedField = nil
                    onLogin()
                }
            )
            .padding(.horizontal, 32)
            .padding(.top, 35)

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.hopesDanger)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
            }

            HStack(spacing: 0) {
                Spacer()

                Button {
                    focusedField = nil
                    onSignUp()
                } label: {
                    Text("계정이 없으신가요?  회원가입")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.hopesTextSecondary)
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(.horizontal, 32)
            .padding(.top, errorMessage == nil ? 21 : 27)
        }
        .frame(minHeight: 502, alignment: .top)
        .frame(maxWidth: .infinity)
        .background {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { focusedField = nil }
        }
        .id(LoginScrollTarget.top)
    }
}

private enum LoginScrollTarget {
    static let top = "login-sheet-top"
}

private extension View {
    @ViewBuilder
    func hopesEmailInputTraits() -> some View {
        #if os(iOS)
        textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
            .textContentType(.username)
        #else
        self
        #endif
    }

    @ViewBuilder
    func hopesPasswordInputTraits() -> some View {
        #if os(iOS)
        textContentType(.password)
        #else
        self
        #endif
    }
}

#Preview("로그인 전체 시트") {
    @Previewable @State var email = ""
    @Previewable @State var password = ""

    LoginView(
        email: $email,
        password: $password
    )
    .frame(width: 402, height: 874)
}
