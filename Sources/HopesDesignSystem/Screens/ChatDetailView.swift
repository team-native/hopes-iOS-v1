import SwiftUI

public struct ChatDetailView: View {
    @State private var selectedTab: HopesTab = .chat
    @Binding private var reply: String

    private let title: String
    private let messages: [MessageResponse]
    private let isLoading: Bool
    private let isSending: Bool
    private let errorMessage: String?
    private let onBack: () -> Void
    private let onSend: (String) -> Void
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
        self.onSend = onSend
        self.onSelectTab = onSelectTab
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color.hopesBackground

            header
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 72)

            messageList
                .padding(.top, 132)
                .padding(.bottom, 158)

            composer
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 84)

            HopesTabBar(selection: $selectedTab, onSelect: onSelectTab)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
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
            Spacer()
        }
    }

    private var messageList: some View {
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
                }
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
            }
            .scrollIndicators(.hidden)
            .onChange(of: messages.count) {
                if let lastID = messages.last?.id {
                    withAnimation { proxy.scrollTo(lastID, anchor: .bottom) }
                }
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
