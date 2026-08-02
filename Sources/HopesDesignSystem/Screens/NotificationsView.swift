import SwiftUI

public struct NotificationsView: View {
    public struct NotificationItem: Identifiable, Sendable {
        public let id: String
        public let title: String
        public let subtitle: String
        public let actionTitle: String
        public var isRead: Bool

        public init(
            title: String,
            subtitle: String,
            actionTitle: String,
            isRead: Bool = false
        ) {
            id = title
            self.title = title
            self.subtitle = subtitle
            self.actionTitle = actionTitle
            self.isRead = isRead
        }
    }

    @State private var selectedTab: HopesTab = .home
    @State private var notifications: [NotificationItem]
    @State private var isEditing = false

    private let onOpenNotification: (NotificationItem) -> Void
    private let onSelectTab: (HopesTab) -> Void

    public init(
        notifications: [NotificationItem] = Self.sampleNotifications,
        onOpenNotification: @escaping (NotificationItem) -> Void = { _ in },
        onSelectTab: @escaping (HopesTab) -> Void = { _ in }
    ) {
        _notifications = State(initialValue: notifications)
        self.onOpenNotification = onOpenNotification
        self.onSelectTab = onSelectTab
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color.hopesBackground

            header
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 76)

            notificationList
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 150)

            HopesButton(
                hasUnreadNotifications ? "모두 읽음 처리" : "모두 읽음",
                size: .large,
                isEnabled: hasUnreadNotifications,
                action: markAllAsRead
            )
            .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
            .padding(.top, 686)

            HopesTabBar(selection: $selectedTab, onSelect: onSelectTab)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 1) {
                Text("알림")
                    .font(.system(size: 27, weight: .bold))
                    .foregroundStyle(Color.hopesTextPrimary)

                Text("새 답변과 공지 알림을 확인해요.")
                    .font(.footnote)
                    .foregroundStyle(Color.hopesTextSecondary)
            }

            Spacer()

            HopesButton(
                isEditing ? "완료" : "편집",
                variant: .secondary,
                size: .small,
                width: .fixed(54)
            ) {
                withAnimation(.easeInOut(duration: 0.18)) {
                    isEditing.toggle()
                }
            }
        }
    }

    private var notificationList: some View {
        VStack(spacing: 12) {
            ForEach(Array(notifications.enumerated()), id: \.element.id) { index, item in
                notificationRow(item, at: index)
            }
        }
    }

    private func notificationRow(
        _ item: NotificationItem,
        at index: Int
    ) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.hopesTextPrimary)

                Text(item.subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.hopesTextSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            if isEditing {
                Button("삭제") {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        notifications.removeAll { $0.id == item.id }
                    }
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.hopesDanger)
                .frame(width: 56, height: 32)
                .background(Color.hopesDangerSurface)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: HopesMetrics.controlCornerRadius
                    )
                )
                .buttonStyle(.plain)
            } else {
                HopesButton(
                    item.isRead ? "읽음" : item.actionTitle,
                    variant: .secondary,
                    size: .compact,
                    width: .fixed(56)
                ) {
                    openNotification(at: index)
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 72)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius)
        )
        .overlay {
            RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius)
                .stroke(Color.hopesBorder, lineWidth: 1)
        }
        .opacity(item.isRead ? 0.72 : 1)
    }

    private var hasUnreadNotifications: Bool {
        notifications.contains { !$0.isRead }
    }

    private func openNotification(at index: Int) {
        let notification = notifications[index]
        notifications[index].isRead = true
        onOpenNotification(notification)
    }

    private func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }

    public static let sampleNotifications: [NotificationItem] = [
        NotificationItem(
            title: "새 답변 도착",
            subtitle: "기숙사 질문에 선배 답변이 도착했어요.",
            actionTitle: "보기"
        ),
        NotificationItem(
            title: "프로필 저장 완료",
            subtitle: "개인화 정보가 반영됐어요.",
            actionTitle: "확인"
        ),
        NotificationItem(
            title: "입학 안내 업데이트",
            subtitle: "면접 준비 질문이 추가됐어요.",
            actionTitle: "열기"
        ),
        NotificationItem(
            title: "시스템 공지",
            subtitle: "답변 데이터 업데이트 완료",
            actionTitle: "보기"
        ),
    ]
}

#Preview("알림") {
    NotificationsView()
        .frame(width: 402, height: 874)
}
