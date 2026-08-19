import SwiftUI

public struct ConversationHistoryView: View {
    public struct Conversation: Identifiable, Sendable {
        public enum Period: Sendable {
            case recent
            case older
        }

        public let id: Int64
        public let title: String
        public let period: Period

        public init(id: Int64 = 0, title: String, period: Period) {
            self.id = id
            self.title = title
            self.period = period
        }
    }

    @State private var selectedTab: HopesTab = .history
    @State private var query = ""
    @FocusState private var isSearchFocused: Bool

    private let conversations: [Conversation]
    private let isLoading: Bool
    private let errorMessage: String?
    private let onNewConversation: () -> Void
    private let onSelectConversation: (Conversation) -> Void
    private let onSearch: (String?) -> Void
    private let onSelectTab: (HopesTab) -> Void

    public init(
        conversations: [Conversation] = [],
        isLoading: Bool = false,
        errorMessage: String? = nil,
        onNewConversation: @escaping () -> Void = {},
        onSelectConversation: @escaping (Conversation) -> Void = { _ in },
        onSearch: @escaping (String?) -> Void = { _ in },
        onSelectTab: @escaping (HopesTab) -> Void = { _ in }
    ) {
        self.conversations = conversations
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.onNewConversation = onNewConversation
        self.onSelectConversation = onSelectConversation
        self.onSearch = onSearch
        self.onSelectTab = onSelectTab
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color.hopesBackground
                .contentShape(Rectangle())
                .onTapGesture { isSearchFocused = false }

            header
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 76)

            HopesButton(
                "+  새 대화 시작",
                variant: .secondary,
                size: .large,
                action: {
                    isSearchFocused = false
                    onNewConversation()
                }
            )
            .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
            .padding(.top, 144)

            searchBar
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 208)

            conversationList
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 282)

            HopesTabBar(selection: $selectedTab, onSelect: onSelectTab)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("지난 대화")
                .font(.system(size: 27, weight: .bold))
                .foregroundStyle(Color.hopesTextPrimary)

            Text("웹사이트 구성을 리스트로 정리했어요.")
                .font(.footnote)
                .foregroundStyle(Color.hopesTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var searchBar: some View {
        HStack(spacing: 0) {
            TextField("지난 대화 검색", text: $query)
                .font(.footnote)
                .foregroundStyle(Color.hopesTextPrimary)
                .padding(.horizontal, 20)
                .frame(height: 41)
                .focused($isSearchFocused)
                .submitLabel(.search)
                .onSubmit(performSearch)

            Button(action: performSearch) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.hopesTextPrimary)
                    .frame(width: 38, height: 41)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("지난 대화 검색")
        }
        .frame(height: 41)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius)
                .stroke(Color.hopesBorder, lineWidth: 1)
        }
    }

    private var conversationList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                if isLoading {
                    ProgressView("대화 목록을 불러오는 중...")
                        .frame(maxWidth: .infinity)
                        .padding(.top, 32)
                } else if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(Color.hopesDanger)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 32)
                } else if conversations.isEmpty {
                    Text("아직 저장된 대화가 없어요.")
                        .font(.footnote)
                        .foregroundStyle(Color.hopesTextPlaceholder)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 32)
                }

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
        .scrollDismissesKeyboard(.interactively)
        .simultaneousGesture(
            TapGesture().onEnded { isSearchFocused = false }
        )
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
                    isSearchFocused = false
                    onSelectConversation(conversation)
                } label: {
                    Text(conversation.title)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(
                            Color.hopesTextPrimary
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

    private func performSearch() {
        isSearchFocused = false
        onSearch(trimmedQuery.isEmpty ? nil : trimmedQuery)
    }

}

#Preview("지난 대화") {
    ConversationHistoryView(
        conversations: [
            .init(id: 1, title: "기숙사 하루 일과가 어떻게 돼?", period: .recent),
            .init(id: 2, title: "입학하려면 뭘 준비해야 해?", period: .older),
        ]
    )
        .frame(width: 402, height: 874)
}
