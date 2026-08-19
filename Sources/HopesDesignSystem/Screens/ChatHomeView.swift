import SwiftUI
import UIKit

public struct ChatHomeView: View {
    @State private var selectedTab: HopesTab = .chat
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
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                fixedDesign
                    .offset(y: -keyboardShift(in: geometry))

                composer
                    .padding(.horizontal, 24)
                    .padding(.top, composerTop(in: geometry))

                if !isInputFocused && keyboardFrame == nil {
                    HopesTabBar(selection: $selectedTab, onSelect: onSelectTab)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea(.container, edges: .bottom)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onChange(of: isInputFocused) { _, isFocused in
                if !isFocused {
                    withAnimation(.easeOut(duration: keyboardAnimationDuration)) {
                        keyboardFrame = nil
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
                updateKeyboardAnimation(from: notification)
                withAnimation(.easeOut(duration: keyboardAnimationDuration)) {
                    keyboardFrame = nil
                }
            }
        }
        .background(Color.hopesBackground.ignoresSafeArea())
        .ignoresSafeArea(.container, edges: .top)
        .ignoresSafeArea(.keyboard, edges: .bottom)
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

        updateKeyboardAnimation(from: notification)

        let convertedFrame = globalKeyboardFrame(for: frame)
        withAnimation(.easeOut(duration: keyboardAnimationDuration)) {
            keyboardFrame = convertedFrame
        }
    }

    private func globalKeyboardFrame(for screenFrame: CGRect) -> CGRect {
        #if os(iOS)
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap(\.windows)
            .first(where: { $0.isKeyWindow }) else {
            return screenFrame
        }

        return window.convert(screenFrame, from: window.screen.coordinateSpace)
        #else
        return screenFrame
        #endif
    }

    private func updateKeyboardAnimation(from notification: Notification) {
        if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            keyboardAnimationDuration = duration
        }
    }

    private func keyboardShift(in geometry: GeometryProxy) -> CGFloat {
        guard isInputFocused, let keyboardFrame else {
            return 0
        }

        let rootFrame = geometry.frame(in: .global)
        let keyboardTop = keyboardFrame.minY - rootFrame.minY
        let composerTop = max(0, keyboardTop - 12 - 52)

        return max(0, 728 - composerTop)
    }

    private func composerTop(in geometry: GeometryProxy) -> CGFloat {
        728 - keyboardShift(in: geometry)
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

#Preview("채팅 홈") {
    @Previewable @State var message = ""

    ChatHomeView(message: $message)
        .frame(width: 402, height: 874)
}
