import SwiftUI

public struct SettingsView: View {
    @State private var selectedTab: HopesTab = .settings

    private let contactEmail: String
    private let onBackToChat: () -> Void
    private let onOpenGeneral: () -> Void
    private let onOpenPersonalSettings: () -> Void
    private let onOpenContact: () -> Void
    private let onLogout: () -> Void
    private let isDeletingAccount: Bool
    private let accountDeletionErrorMessage: String?
    private let onDeleteAccount: (String) -> Void
    private let onSelectTab: (HopesTab) -> Void
    private let isLoggingOut: Bool
    private let errorMessage: String?
    @State private var isDeletionSheetPresented = false
    @State private var deletionPasswordAwaitingConfirmation: String?
    @State private var pendingDeletionPassword: String?

    public init(
        contactEmail: String = "gsm-chatbot@gsm.hs.kr",
        isLoggingOut: Bool = false,
        isDeletingAccount: Bool = false,
        accountDeletionErrorMessage: String? = nil,
        errorMessage: String? = nil,
        onBackToChat: @escaping () -> Void = {},
        onOpenGeneral: @escaping () -> Void = {},
        onOpenPersonalSettings: @escaping () -> Void = {},
        onOpenContact: @escaping () -> Void = {},
        onLogout: @escaping () -> Void = {},
        onDeleteAccount: @escaping (String) -> Void = { _ in },
        onSelectTab: @escaping (HopesTab) -> Void = { _ in }
    ) {
        self.contactEmail = contactEmail
        self.isLoggingOut = isLoggingOut
        self.isDeletingAccount = isDeletingAccount
        self.accountDeletionErrorMessage = accountDeletionErrorMessage
        self.errorMessage = errorMessage
        self.onBackToChat = onBackToChat
        self.onOpenGeneral = onOpenGeneral
        self.onOpenPersonalSettings = onOpenPersonalSettings
        self.onOpenContact = onOpenContact
        self.onLogout = onLogout
        self.onDeleteAccount = onDeleteAccount
        self.onSelectTab = onSelectTab
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color.hopesBackground

            header
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 76)

            HopesActionRow(
                title: "개인 설정",
                subtitle: "시스템 프롬프트 관리",
                action: onOpenPersonalSettings
            )
            .frame(width: 314)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 37)
            .padding(.top, 150)

            HopesActionRow(
                title: "문의하기",
                subtitle: contactEmail,
                action: onOpenContact
            )
            .frame(width: 314)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 37)
            .padding(.top, 217)

            accountActions
                .padding(.horizontal, 29)
                .padding(.top, 318)

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(Color.hopesDanger)
                    .padding(.horizontal, 30)
                    .padding(.top, 490)
            }

            HopesTabBar(selection: $selectedTab, onSelect: onSelectTab)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()
        .sheet(isPresented: $isDeletionSheetPresented, onDismiss: {
            guard let password = deletionPasswordAwaitingConfirmation else { return }
            pendingDeletionPassword = password
            deletionPasswordAwaitingConfirmation = nil
        }) {
            AccountDeletionView(
                isDeleting: isDeletingAccount,
                errorMessage: accountDeletionErrorMessage,
                onCancel: { isDeletionSheetPresented = false },
                onContinue: { password in
                    deletionPasswordAwaitingConfirmation = password
                    isDeletionSheetPresented = false
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .interactiveDismissDisabled(isDeletingAccount)
        }
        .confirmationDialog(
            "정말 회원탈퇴 하시겠어요?",
            isPresented: Binding(
                get: { pendingDeletionPassword != nil },
                set: { isPresented in
                    if !isPresented {
                        pendingDeletionPassword = nil
                    }
                }
            ),
            titleVisibility: .visible
        ) {
            Button("회원탈퇴", role: .destructive) {
                guard let password = pendingDeletionPassword else { return }
                pendingDeletionPassword = nil
                onDeleteAccount(password)
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("계정과 학습 기록은 복구할 수 없습니다.")
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onBackToChat) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.hopesBrandPrimary)
                    .frame(width: 38, height: 38)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .overlay {
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(Color.hopesBorder, lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("마이페이지로 돌아가기")

            VStack(alignment: .leading, spacing: 2) {
                Text("설정")
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color.hopesTextPrimary)

                Text("앱 설정과 도움말을 관리해요.")
                    .font(.footnote)
                    .foregroundStyle(Color.hopesTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var accountActions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("계정")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.hopesTextSecondary)
                .padding(.leading, 8)

            VStack(spacing: 0) {
                accountActionRow(
                    title: isLoggingOut ? "로그아웃 중..." : "로그아웃",
                    icon: "rectangle.portrait.and.arrow.right",
                    isEnabled: !isLoggingOut,
                    action: onLogout
                )

                Divider()
                    .padding(.leading, 52)

                accountActionRow(
                    title: "회원탈퇴",
                    icon: "person.crop.circle.badge.xmark",
                    action: { isDeletionSheetPresented = true }
                )
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius)
                    .stroke(Color.hopesBorder, lineWidth: 1)
            }
        }
    }

    private func accountActionRow(
        title: String,
        icon: String,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .medium))
                    .frame(width: 24)

                Text(title)
                    .font(.subheadline.weight(.semibold))

                Spacer()

                if isLoggingOut && title == "로그아웃 중..." {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                }
            }
            .foregroundStyle(Color.hopesDanger)
            .frame(maxWidth: .infinity, minHeight: 56)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.55)
    }

}

#Preview("설정") {
    SettingsView()
        .frame(width: 402, height: 874)
}
