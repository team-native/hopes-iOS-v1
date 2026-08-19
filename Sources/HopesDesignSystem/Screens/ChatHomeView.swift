import SwiftUI
import UIKit

public struct ChatHomeView: View {
    @State private var selectedTab: HopesTab = .chat
    @State private var keyboardOffset: CGFloat = 0
    @State private var inputBottom: CGFloat = 0
    @State private var keyboardFrame: CGRect?
    @State private var keyboardAnimationDuration: Double = 0.25
    @Binding private var message: String
    @FocusState private var isInputFocused: Bool

    private let onNewChat: () -> Void
    private let onSend: (String) -> Void
    private let onSelectTab: (HopesTab) -> Void

    private let suggestions = [
        ("⌂", "기숙사 하루 일과가 어떻게 돼?"),
        ("◇", "입학하려면 뭘 준비해야 해?"),
        ("<>", "전공 선택은 어떻게 하는 게 좋아?"),
        ("□", "후배한테 해주고 싶은 조언 있어?"),
    ]

    public init(
        message: Binding<String>,
        onNewChat: @escaping () -> Void = {},
        onSend: @escaping (String) -> Void = { _ in },
        onSelectTab: @escaping (HopesTab) -> Void = { _ in }
    ) {
        _message = message
        self.onNewChat = onNewChat
        self.onSend = onSend
        self.onSelectTab = onSelectTab
    }

    public var body: some View {
        GeometryReader { _ in
            ZStack(alignment: .top) {
                fixedDesign
                    .offset(y: keyboardOffset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .onPreferenceChange(ChatHomeInputBottomPreferenceKey.self) { bottom in
                inputBottom = bottom
                updateKeyboardOffset()
            }
            .onChange(of: isInputFocused) { _, isFocused in
                if !isFocused {
                    resetKeyboardOffset()
                } else {
                    // Focus changes before UIKit has finished laying out the
                    // keyboard. Recalculate once the next layout pass has
                    // produced the input field's global frame.
                    Task { @MainActor in
                        await Task.yield()
                        updateKeyboardOffset()
                    }
                }
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: UIResponder.keyboardWillChangeFrameNotification
                )
            ) { notification in
                updateKeyboardFrame(from: notification)
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: UIResponder.keyboardWillShowNotification
                )
            ) { notification in
                updateKeyboardFrame(from: notification)
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: UIResponder.keyboardWillHideNotification
                )
            ) { notification in
                keyboardFrame = nil
                updateKeyboardAnimation(from: notification)
                resetKeyboardOffset()
            }
        }
        .background(Color.hopesBackground.ignoresSafeArea())
        .ignoresSafeArea(.container, edges: .top)
    }

    private var fixedDesign: some View {
        ZStack(alignment: .top) {
            Color.hopesBackground
                .contentShape(Rectangle())
                .onTapGesture { isInputFocused = false }

            header
                .padding(.horizontal, 24)
                .padding(.top, 72)
                .simultaneousGesture(
                    TapGesture().onEnded { isInputFocused = false }
                )

            HopesLogo(size: .large)
                .padding(.top, 184)
                .contentShape(Rectangle())
                .simultaneousGesture(
                    TapGesture().onEnded { isInputFocused = false }
                )

            VStack(spacing: 7) {
                Text("무엇이 궁금한가요?")
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color.hopesTextPrimary)

                Text("광주소프트웨어마이스터고 선배에게 편하게 물어보세요.")
                    .font(.footnote)
                    .foregroundStyle(Color.hopesTextSecondary)
                    .multilineTextAlignment(.center)
                    .frame(width: 318)
            }
            .padding(.top, 283)
            .simultaneousGesture(
                TapGesture().onEnded { isInputFocused = false }
            )

            VStack(spacing: 6) {
                ForEach(suggestions, id: \.1) { icon, title in
                    HopesQuestionCard(title: title) {
                        isInputFocused = false
                        message = title
                    } icon: {
                        Text(icon)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 396)
            .simultaneousGesture(
                TapGesture().onEnded { isInputFocused = false }
            )

            composer
                .padding(.horizontal, 24)
                .padding(.top, 728)

            if !isInputFocused {
                HopesTabBar(selection: $selectedTab, onSelect: onSelectTab)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea(.container, edges: .bottom)
    }

    private func updateKeyboardFrame(from notification: Notification) {
        guard
            let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            frame.height > 0
        else {
            return
        }

        keyboardFrame = globalKeyboardFrame(for: frame)
        updateKeyboardAnimation(from: notification)

        // The keyboard notification and SwiftUI geometry preference can land
        // in different layout passes. Let both state updates settle before
        // calculating the translation for the complete fixed design.
        Task { @MainActor in
            await Task.yield()
            updateKeyboardOffset()
        }
    }

    private func globalKeyboardFrame(for screenFrame: CGRect) -> CGRect {
        // `keyboardFrameEndUserInfoKey` and SwiftUI's `.global` geometry are
        // both expressed in the simulator's screen coordinate space here.
        // Converting through UIWindow could introduce a second coordinate
        // transform and leave the calculated overlap at zero.
        return screenFrame
    }

    private func updateKeyboardAnimation(from notification: Notification) {
        if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            keyboardAnimationDuration = duration
        }
    }

    private func updateKeyboardOffset() {
        guard isInputFocused, let keyboardFrame, inputBottom > 0 else {
            resetKeyboardOffset()
            return
        }

        // `inputBottom` includes the currently applied offset. Remove it first
        // so repeated frame/preference updates always calculate from the
        // original Figma layout position.
        let unshiftedInputBottom = inputBottom - keyboardOffset
        let overlap = max(0, unshiftedInputBottom - keyboardFrame.minY)
        let targetOffset = -overlap

        guard abs(targetOffset - keyboardOffset) > 0.5 else {
            return
        }

        withAnimation(.easeOut(duration: keyboardAnimationDuration)) {
            keyboardOffset = targetOffset
        }
    }

    private func resetKeyboardOffset() {
        guard keyboardOffset != 0 else {
            return
        }

        withAnimation(.easeOut(duration: keyboardAnimationDuration)) {
            keyboardOffset = 0
        }
    }

    private var header: some View {
        HStack {
            HopesLogo()

            Spacer()

            HopesButton(
                "새 대화",
                variant: .secondary,
                size: .medium,
                width: .fixed(70)
            ) {
                isInputFocused = false
                message = ""
                onNewChat()
            }
        }
    }

    private var composer: some View {
        HStack(spacing: 8) {
            TextField("선배에게 메시지 보내기", text: $message)
                .font(.footnote)
                .foregroundStyle(Color.hopesTextPrimary)
                .focused($isInputFocused)
                .onSubmit(sendMessage)

            Button(action: sendMessage) {
                Image(systemName: "arrow.up")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(Color.hopesBrandPrimary)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: HopesMetrics.controlCornerRadius
                        )
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("메시지 보내기")
        }
        .padding(.leading, 14)
        .padding(.trailing, 18)
        .frame(height: 52)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius)
                .stroke(Color.hopesBorder, lineWidth: 1)
        }
        .background {
            GeometryReader { geometry in
                Color.clear
                    .preference(
                        key: ChatHomeInputBottomPreferenceKey.self,
                        value: geometry.frame(in: .global).maxY
                    )
            }
        }
        .shadow(
            color: Color(red: 13 / 255, green: 26 / 255, blue: 46 / 255)
                .opacity(0.07),
            radius: 8,
            y: 6
        )
    }

    private var trimmedMessage: String {
        message.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func sendMessage() {
        guard !trimmedMessage.isEmpty, trimmedMessage.count <= 12_000 else {
            return
        }

        onSend(trimmedMessage)
    }
}

private struct ChatHomeInputBottomPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview("채팅 홈") {
    @Previewable @State var message = ""

    ChatHomeView(message: $message)
        .frame(width: 402, height: 874)
}
