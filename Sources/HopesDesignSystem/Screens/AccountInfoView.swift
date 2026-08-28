import SwiftUI

public struct AccountInfoView: View {
    @State private var selectedTab: HopesTab = .settings

    private let email: String
    private let major: String
    private let cohort: String
    private let isSchoolVerified: Bool
    private let onBack: () -> Void
    private let onDone: () -> Void
    private let isDeletingAccount: Bool
    private let accountDeletionErrorMessage: String?
    private let onDeleteAccount: (String) -> Void
    private let onSelectTab: (HopesTab) -> Void
    @State private var isDeletionSheetPresented = false

    public init(
        email: String = "s26055@gsm.hs.kr",
        major: String = "인공지능소프트웨어과",
        cohort: String = "10기",
        isSchoolVerified: Bool = true,
        isDeletingAccount: Bool = false,
        accountDeletionErrorMessage: String? = nil,
        onBack: @escaping () -> Void = {},
        onDone: @escaping () -> Void = {},
        onDeleteAccount: @escaping (String) -> Void = { _ in },
        onSelectTab: @escaping (HopesTab) -> Void = { _ in }
    ) {
        self.email = email
        self.major = major
        self.cohort = cohort
        self.isSchoolVerified = isSchoolVerified
        self.isDeletingAccount = isDeletingAccount
        self.accountDeletionErrorMessage = accountDeletionErrorMessage
        self.onBack = onBack
        self.onDone = onDone
        self.onDeleteAccount = onDeleteAccount
        self.onSelectTab = onSelectTab
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color.hopesBackground

            header
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 72)

            accountCard
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 156)

            HopesButton(
                "회원탈퇴",
                variant: .danger,
                width: .fixed(330),
                action: { isDeletionSheetPresented = true }
            )
            .padding(.top, 470)

            HopesTabBar(selection: $selectedTab, onSelect: onSelectTab)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()
        .sheet(isPresented: $isDeletionSheetPresented) {
            AccountDeletionView(
                isDeleting: isDeletingAccount,
                errorMessage: accountDeletionErrorMessage,
                onCancel: { isDeletionSheetPresented = false },
                onContinue: onDeleteAccount
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .interactiveDismissDisabled(isDeletingAccount)
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onBack) {
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
                Text("계정 정보")
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color.hopesTextPrimary)

                Text("학교 인증 정보는 수정할 수 없어요.")
                    .font(.footnote)
                    .foregroundStyle(Color.hopesTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HopesButton(
                "완료",
                variant: .secondary,
                size: .small,
                width: .fixed(54),
                action: onDone
            )
        }
    }

    private var accountCard: some View {
        HopesCard(padding: 24) {
            VStack(alignment: .leading, spacing: 0) {
                Text("계정 정보")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.hopesTextPrimary)

                Text("이메일: \(email)")
                    .padding(.top, 24)

                Text("전공: \(major)")
                    .padding(.top, 20)

                Text("기수: \(cohort)")
                    .padding(.top, 20)

                Text("학교 인증 상태: \(isSchoolVerified ? "완료" : "미완료")")
                    .foregroundStyle(isSchoolVerified ? Color.hopesSuccess : Color.hopesDanger)
                    .padding(.top, 20)
            }
            .font(.subheadline)
            .foregroundStyle(Color.hopesTextPrimary)
            .padding(.top, 4)
        }
        .frame(height: 284)
    }

}

#Preview("계정 정보") {
    AccountInfoView()
        .frame(width: 402, height: 874)
}

struct AccountDeletionView: View {
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
