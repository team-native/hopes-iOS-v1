import SwiftUI
import UIKit

public struct LoginView: View {
    enum LoginField: Hashable {
        case email
        case password
    }

    @State var isPasswordVisible = false
    @State var sheetProgress: CGFloat
    @State var sheetDragStartProgress: CGFloat?
    @Binding var email: String
    @Binding var password: String
    @FocusState var focusedField: LoginField?

    let onLogin: () -> Void
    let onSignUp: () -> Void
    let onForgotPassword: () -> Void
    let isLoading: Bool
    let errorMessage: String?

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
            // Designed-for-iPhone compatibility can expose a shorter effective
            // height than a full iPhone screen. Preserve the Figma spacing on
            // regular heights, but make room between the hero copy and cue on
            // compact heights.
            let heroTopPadding = min(168, max(80, geometry.size.height - 615))
            let swipeCueBottomPadding: CGFloat = geometry.size.height < 800 ? 150 : 190

            ZStack(alignment: .bottom) {
                Color.white
                    .ignoresSafeArea()

                Color.hopesHeroGradient
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

                loginSheet()
                    .offset(y: sheetOffset)
                    .simultaneousGesture(sheetDragGesture(collapsedOffset: collapsedOffset))
            }
        }
        .ignoresSafeArea(.container, edges: [.top, .bottom])
        .preferredColorScheme(.light)
        .onAppear {
            Task { @MainActor in
                await Task.yield()
                applyLightKeyboardAppearanceToInputs()
            }
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
