import SwiftUI

public struct ConversationHistoryView: View {
    public struct Conversation: Identifiable, Sendable {
        public enum Period: Sendable {
            case recent
            case older
        }

        public let id: String
        public let title: String
        public let period: Period

        public init(title: String, period: Period) {
            id = title
            self.title = title
            self.period = period
        }
    }

    @State private var selectedTab: HopesTab = .history
    @State private var query = ""
    @FocusState private var isSearchFocused: Bool

    private let conversations: [Conversation]
    private let onNewConversation: () -> Void
    private let onSelectConversation: (Conversation) -> Void

    public init(
        conversations: [Conversation] = Self.sampleConversations,
        onNewConversation: @escaping () -> Void = {},
        onSelectConversation: @escaping (Conversation) -> Void = { _ in }
    ) {
        self.conversations = conversations
        self.onNewConversation = onNewConversation
        self.onSelectConversation = onSelectConversation
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color.hopesBackground

            header
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 76)

            HopesButton(
                "+  새 대화 시작",
                variant: .secondary,
                size: .large,
                action: onNewConversation
            )
            .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
            .padding(.top, 144)

            searchBar
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 208)

            conversationList
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 282)

            HopesTabBar(selection: $selectedTab)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 1) {
                Text("지난 대화")
                    .font(.system(size: 27, weight: .bold))
                    .foregroundStyle(Color.hopesTextPrimary)

                Text("웹사이트 구성을 리스트로 정리했어요.")
                    .font(.footnote)
                    .foregroundStyle(Color.hopesTextSecondary)
            }

            Spacer()

            HopesButton(
                "검색",
                variant: .secondary,
                size: .small,
                width: .fixed(54)
            ) {
                isSearchFocused = true
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            TextField("지난 대화 검색", text: $query)
                .font(.footnote)
                .foregroundStyle(Color.hopesTextPrimary)
                .padding(.horizontal, 20)
                .frame(height: 44)
                .background(.white)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: HopesMetrics.controlCornerRadius
                    )
                )
                .overlay {
                    RoundedRectangle(
                        cornerRadius: HopesMetrics.controlCornerRadius
                    )
                    .stroke(Color.hopesBorder, lineWidth: 1)
                }
                .focused($isSearchFocused)
                .submitLabel(.search)

            Button {
                isSearchFocused = true
            } label: {
                Text("⌕")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.hopesTextPrimary)
                    .frame(width: 52, height: 44)
                    .background(.white)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: HopesMetrics.controlCornerRadius
                        )
                    )
                    .overlay {
                        RoundedRectangle(
                            cornerRadius: HopesMetrics.controlCornerRadius
                        )
                        .stroke(Color.hopesBorder, lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("지난 대화 검색")
        }
    }

    private var conversationList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                conversationSection(
                    title: "지난 7일",
                    conversations: filteredConversations(for: .recent)
                )

                conversationSection(
                    title: "이전",
                    conversations: filteredConversations(for: .older)
                )
                .padding(.top, 20)
            }
        }
        .scrollIndicators(.hidden)
        .frame(height: 420)
    }

    private func conversationSection(
        title: String,
        conversations: [Conversation]
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.footnote.weight(.bold))
                .foregroundStyle(Color.hopesTextSecondary)
                .padding(.bottom, 16)

            ForEach(conversations) { conversation in
                Button {
                    onSelectConversation(conversation)
                } label: {
                    Text(conversation.title)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(
                            conversation.title == Self.sampleConversations.first?.title
                                ? Color.hopesTextPrimary
                                : Color.hopesTextSecondary
                        )
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 46)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            if conversations.isEmpty {
                Text("검색 결과가 없어요.")
                    .font(.footnote)
                    .foregroundStyle(Color.hopesTextPlaceholder)
                    .frame(height: 46)
            }
        }
    }

    private func filteredConversations(
        for period: Conversation.Period
    ) -> [Conversation] {
        conversations.filter { conversation in
            conversation.period == period
                && (
                    trimmedQuery.isEmpty
                        || conversation.title.localizedCaseInsensitiveContains(trimmedQuery)
                )
        }
    }

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public static let sampleConversations: [Conversation] = [
        Conversation(title: "기숙사 하루 일과가 어떻게 돼?", period: .recent),
        Conversation(title: "전공 선택은 어떻게 하는 게 좋...", period: .recent),
        Conversation(title: "여기랑 대덕중에 누가 더 좋음", period: .recent),
        Conversation(title: "입학하려면 뭘 준비해야 해?", period: .older),
        Conversation(title: "과랑 전공이랑 뭐가 다름", period: .older),
        Conversation(title: "후배한테 해주고 싶은 조언 있어?", period: .older),
        Conversation(title: "가장 예쁜 사람 누구?", period: .older),
    ]
}

#Preview("지난 대화") {
    ConversationHistoryView()
        .frame(width: 402, height: 874)
}
