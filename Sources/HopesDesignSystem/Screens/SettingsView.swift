import SwiftUI

public struct SettingsView: View {
    @State var selectedTab: HopesTab = .settings
    @State var isDeletionSheetPresented = false
    @State var deletionPasswordAwaitingConfirmation: String?
    @State var pendingDeletionPassword: String?

    let contactEmail: String
    let onBackToChat: () -> Void
    let onOpenGeneral: () -> Void
    let onOpenPersonalSettings: () -> Void
    let onOpenContact: () -> Void
    let onLogout: () -> Void
    let isDeletingAccount: Bool
    let accountDeletionErrorMessage: String?
    let onDeleteAccount: (String) -> Void
    let onSelectTab: (HopesTab) -> Void
    let isLoggingOut: Bool
    let errorMessage: String?

    public init(
        contactEmail: String = "gsm-chatbot@gsm.hs.kr",
        isLoggingOut: Bool = false,
        errorMessage: String? = nil,
        onBackToChat: @escaping () -> Void = {},
        onOpenGeneral: @escaping () -> Void = {},
        onOpenPersonalSettings: @escaping () -> Void = {},
        onOpenContact: @escaping () -> Void = {},
        onLogout: @escaping () -> Void = {},
        isDeletingAccount: Bool = false,
        accountDeletionErrorMessage: String? = nil,
        onDeleteAccount: @escaping (String) -> Void = { _ in },
        onSelectTab: @escaping (HopesTab) -> Void = { _ in }
    ) {
        self.contactEmail = contactEmail
        self.isLoggingOut = isLoggingOut
        self.errorMessage = errorMessage
        self.onBackToChat = onBackToChat
        self.onOpenGeneral = onOpenGeneral
        self.onOpenPersonalSettings = onOpenPersonalSettings
        self.onOpenContact = onOpenContact
        self.onLogout = onLogout
        self.isDeletingAccount = isDeletingAccount
        self.accountDeletionErrorMessage = accountDeletionErrorMessage
        self.onDeleteAccount = onDeleteAccount
        self.onSelectTab = onSelectTab
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.top, 24)

                HopesActionRow(
                    title: "개인 설정",
                    subtitle: "시스템 프롬프트 관리",
                    action: onOpenPersonalSettings
                )
                .padding(.top, 34)

                HopesActionRow(
                    title: "문의하기",
                    subtitle: contactEmail,
                    action: onOpenContact
                )
                .padding(.top, 12)

                accountActions
                    .padding(.top, 32)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(Color.hopesDanger)
                        .padding(.top, 18)
                }
            }
            .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(Color.hopesBackground.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HopesTabBar(selection: $selectedTab, onSelect: onSelectTab)
        }
        .sheet(isPresented: $isDeletionSheetPresented, onDismiss: {
            guard let password = deletionPasswordAwaitingConfirmation else { return }
            pendingDeletionPassword = password
            deletionPasswordAwaitingConfirmation = nil
        }) {
            SettingsAccountDeletionView(
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
                    if !isPresented { pendingDeletionPassword = nil }
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

}

#Preview("설정") {
    SettingsView()
        .frame(width: 402, height: 874)
}


private struct SettingsAccountDeletionView: View {
    @State private var password = ""
    @FocusState private var isPasswordFocused: Bool

    let isDeleting: Bool
    let errorMessage: String?
    let onCancel: () -> Void
    let onContinue: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("회원탈퇴")
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.hopesTextPrimary)

            Text("탈퇴하면 계정과 학습 기록을 복구할 수 없어요.")
                .font(.subheadline)
                .foregroundStyle(Color.hopesTextSecondary)
                .padding(.top, 8)

            VStack(alignment: .leading, spacing: 6) {
                Text("계정을 삭제하려면 현재 비밀번호를 입력해 주세요.")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.hopesDanger)

                SecureField("현재 비밀번호", text: $password)
                    .textContentType(.password)
                    .font(.subheadline)
                    .padding(.horizontal, 16)
                    .frame(height: HopesMetrics.textFieldHeight)
                    .background(Color.hopesInputBackground)
                    .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius))
                    .overlay {
                        RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius)
                            .stroke(Color.hopesBorder, lineWidth: 1)
                    }
                    .focused($isPasswordFocused)
            }
            .padding(.top, 28)

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(Color.hopesDanger)
                    .padding(.top, 12)
            }

            Spacer(minLength: 24)

            HStack(spacing: 12) {
                HopesButton("취소", variant: .secondary, width: .fill, isEnabled: !isDeleting, action: onCancel)
                HopesButton(
                    isDeleting ? "탈퇴 처리 중..." : "회원탈퇴",
                    variant: .danger,
                    width: .fill,
                    isEnabled: password.count >= 8 && !isDeleting,
                    action: { onContinue(password) }
                )
            }
        }
        .simultaneousGesture(
            TapGesture().onEnded { isPasswordFocused = false },
            including: .gesture
        )
        .padding(24)
    }
}
