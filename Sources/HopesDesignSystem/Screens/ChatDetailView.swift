import SwiftUI

public struct ChatDetailView: View {
    private enum ScrollTarget {
        static let bottom = "chat-message-bottom"
    }

    @State private var selectedTab: HopesTab = .chat
    @State private var isSaved = false
    @Binding private var reply: String
    @FocusState private var isReplyFocused: Bool

    private let title: String
    private let messages: [MessageResponse]
    private let isLoading: Bool
    private let isSending: Bool
    private let errorMessage: String?
    private let onBack: () -> Void
    private let onShowSources: () -> Void
    private let onSend: (String) -> Void
    private let onShare: () -> Void
    private let onSelectTab: (HopesTab) -> Void

    public init(
        reply: Binding<String>,
        title: String = "새 대화",
        messages: [MessageResponse] = [],
        isLoading: Bool = false,
        isSending: Bool = false,
        errorMessage: String? = nil,
        onBack: @escaping () -> Void = {},
        onShowSources: @escaping () -> Void = {},
        onSend: @escaping (String) -> Void = { _ in },
        onShare: @escaping () -> Void = {},
        onSelectTab: @escaping (HopesTab) -> Void = { _ in }
    ) {
        _reply = reply
        self.title = title
        self.messages = messages
        self.isLoading = isLoading
        self.isSending = isSending
        self.errorMessage = errorMessage
        self.onBack = onBack
        self.onShowSources = onShowSources
        self.onSend = onSend
        self.onShare = onShare
        self.onSelectTab = onSelectTab
    }

    public var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 16)
                .padding(.bottom, 20)
                .simultaneousGesture(
                    TapGesture().onEnded { isReplyFocused = false }
                )

            messageList
        }
        .background(Color.hopesBackground.ignoresSafeArea())
        // 키보드가 표시되면 시스템 Safe Area가 작성 영역을 자동으로 위로 밀어 올립니다.
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                composer

                if !isReplyFocused {
                    HopesTabBar(selection: $selectedTab) { tab in
                        isReplyFocused = false
                        onSelectTab(tab)
                    }
                }
            }
            .background(Color.hopesBackground)
        }
        .contentShape(Rectangle())
        .onTapGesture { isReplyFocused = false }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button {
                isReplyFocused = false
                onBack()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.hopesBrandPrimary)
                    .frame(width: 38, height: 38)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .overlay {
                        RoundedRectangle(cornerRadius: 13).stroke(Color.hopesBorder, lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("뒤로")

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.hopesTextPrimary)
                    .lineLimit(1)
                Text("홉스 AI 답변")
                    .font(.footnote)
                    .foregroundStyle(Color.hopesTextSecondary)
            }
            Spacer(minLength: 8)

            HopesButton(
                isSaved ? "저장됨" : "저장",
                variant: .secondary,
                size: .small,
                width: .fixed(isSaved ? 64 : 54)
            ) {
                isReplyFocused = false
                isSaved.toggle()
            }
        }
    }

    private var messageList: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if isLoading {
                            ProgressView("대화를 불러오는 중...")
                                .padding(.top, 32)
                        } else if messages.isEmpty {
                            Text("질문을 보내면 AI 답변이 여기에 표시돼요.")
                                .font(.footnote)
                                .foregroundStyle(Color.hopesTextPlaceholder)
                                .padding(.top, 32)
                        }

                        ForEach(messages) { message in
                            messageBubble(message)
                                .id(message.id)
                        }

                        if isSending {
                            HStack(spacing: 8) {
                                ProgressView()
                                Text("AI가 답변을 만들고 있어요.")
                                    .font(.footnote)
                                    .foregroundStyle(Color.hopesTextSecondary)
                                Spacer()
                            }
                            .padding(16)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius))
                        }

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundStyle(Color.hopesDanger)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Color.clear
                            .frame(height: 1)
                            .id(ScrollTarget.bottom)
                    }
                    .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
                .simultaneousGesture(
                    TapGesture().onEnded { isReplyFocused = false }
                )
                .onAppear {
                    scrollToBottom(proxy, animated: false)
                }
                .onChange(of: messages.count) {
                    scrollToBottom(proxy)
                }
                .onChange(of: isReplyFocused) { _, isFocused in
                    guard isFocused else { return }
                    scrollToBottom(proxy)
                }
                .onChange(of: geometry.size.height) { _, _ in
                    // The keyboard changes the available container height after
                    // focus changes. Resolve the anchor again after that layout
                    // pass so the answer's last content stays above the composer.
                    guard isReplyFocused else { return }
                    scrollToBottom(proxy, animated: false)
                }
                .onChange(of: geometry.safeAreaInsets.bottom) { _, _ in
                    // Some devices report the keyboard change through the safe
                    // area without changing the container's measured height.
                    guard isReplyFocused else { return }
                    scrollToBottom(proxy, animated: false)
                }
            }
        }
    }

    private func scrollToBottom(
        _ proxy: ScrollViewProxy,
        animated: Bool = true
    ) {
        Task { @MainActor in
            // Wait for the Safe Area resize to be reflected in the ScrollView
            // before resolving the bottom anchor.
            await Task.yield()

            if animated {
                withAnimation {
                    proxy.scrollTo(ScrollTarget.bottom, anchor: .bottom)
                }
            } else {
                proxy.scrollTo(ScrollTarget.bottom, anchor: .bottom)
            }
        }
    }

    private func messageBubble(_ message: MessageResponse) -> some View {
        HStack {
            if message.role == .user { Spacer(minLength: 64) }
            Text(message.content)
                .font(.subheadline)
                .foregroundStyle(message.role == .user ? .white : Color.hopesTextPrimary)
                .lineSpacing(2)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(message.role == .user ? Color.hopesBrandPrimary : .white)
                .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius))
                .overlay {
                    if message.role == .assistant {
                        RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius)
                            .stroke(Color.hopesBorder, lineWidth: 1)
                    }
                }
            if message.role == .assistant { Spacer(minLength: 40) }
        }
    }

    private var composer: some View {
        HStack(spacing: 14) {
            TextField("추가 질문 입력", text: $reply)
                .font(.footnote)
                .focused($isReplyFocused)
                .padding(.horizontal, 20)
                .frame(height: 44)
                .background(Color.hopesInputBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay { RoundedRectangle(cornerRadius: 16).stroke(Color.hopesBorder, lineWidth: 1) }
                .onSubmit(sendReply)
                .disabled(isSending)

            Button(isSending ? "전송 중" : "전송", action: sendReply)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 64, height: 44)
                .background(Color.hopesBrandPrimary)
                .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius))
                .disabled(trimmedReply.isEmpty || isSending)
                .opacity(trimmedReply.isEmpty || isSending ? 0.45 : 1)
        }
        .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
        .frame(height: 74)
        .background(.white)
        .overlay(alignment: .top) { Rectangle().fill(Color.hopesBorder).frame(height: 1) }
    }

    private var trimmedReply: String {
        reply.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func sendReply() {
        guard !trimmedReply.isEmpty, trimmedReply.count <= 12_000, !isSending else { return }
        let content = trimmedReply
        reply = ""
        onSend(content)
    }
}

#Preview("채팅 상세") {
    @Previewable @State var reply = ""
    ChatDetailView(reply: $reply)
        .frame(width: 402, height: 874)
}
