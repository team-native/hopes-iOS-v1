import SwiftUI
import UIKit

public struct ChatHomeView: View {
    @State private var selectedTab: HopesTab = .chat
    @State private var isKeyboardVisible = false
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
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                fixedDesign
                    .frame(height: 728)
                    .id("chat-home-top")
            }
            .scrollDisabled(!isInputFocused)
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: 0) {
                    composer
                        .padding(.horizontal, 24)

                    if !isInputFocused && !isKeyboardVisible {
                        Color.clear
                            .frame(height: 10)

                        HopesTabBar(selection: $selectedTab, onSelect: onSelectTab)
                    } else {
                        Color.clear
                            .frame(height: 10)
                    }
                }
                .background(Color.hopesBackground)
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: UIResponder.keyboardWillShowNotification
                )
            ) { _ in
                isKeyboardVisible = true
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: UIResponder.keyboardDidShowNotification
                )
            ) { _ in
                withAnimation(.easeOut(duration: 0.2)) {
                    proxy.scrollTo(1, anchor: .bottom)
                }
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: UIResponder.keyboardWillHideNotification
                )
            ) { _ in
                isKeyboardVisible = false
                withAnimation(.easeOut(duration: 0.2)) {
                    proxy.scrollTo("chat-home-top", anchor: .top)
                }
            }
            .background(Color.hopesBackground.ignoresSafeArea())
            .ignoresSafeArea(.container, edges: [.top, .bottom])
        }
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
                ForEach(suggestions.indices, id: \.self) { index in
                    HopesQuestionCard(title: suggestions[index].1) {
                        isInputFocused = false
                        message = suggestions[index].1
                    } icon: {
                        Text(suggestions[index].0)
                    }
                    .id(index)
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
