import SwiftUI

public struct ChatHomeView: View {
    @State private var selectedTab: HopesTab = .chat
    @State private var keyboardOffset: CGFloat = 0
    @State private var inputBottom: CGFloat = 0
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
                    .coordinateSpace(name: ChatHomeCoordinateSpace.name)
                    .offset(y: keyboardOffset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .onPreferenceChange(ChatHomeInputBottomPreferenceKey.self) { bottom in
                inputBottom = bottom
                updateKeyboardOffset(in: geometry)
            }
            .onChange(of: isInputFocused) { _, isFocused in
                if !isFocused {
                    keyboardOffset = 0
                } else {
                    updateKeyboardOffset(in: geometry)
                }
            }
            .onChange(of: geometry.safeAreaInsets.bottom) { _, _ in
                updateKeyboardOffset(in: geometry)
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
    }

    private func updateKeyboardOffset(in geometry: GeometryProxy) {
        guard isInputFocused, inputBottom > 0 else {
            keyboardOffset = 0
            return
        }

        let availableBottom = geometry.frame(in: .global).maxY - geometry.safeAreaInsets.bottom
        keyboardOffset = min(0, availableBottom - inputBottom)
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
                        value: geometry.frame(in: .named(ChatHomeCoordinateSpace.name)).maxY
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

private enum ChatHomeCoordinateSpace {
    static let name = "chat-home-fixed-design"
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
