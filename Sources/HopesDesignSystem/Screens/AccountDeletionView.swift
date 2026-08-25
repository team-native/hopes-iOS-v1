import SwiftUI

public struct AccountDeletionView: View {
    @State private var password = ""

    private let isDeleting: Bool
    private let errorMessage: String?
    private let onCancel: () -> Void
    private let onContinue: (String) -> Void

    public init(
        isDeleting: Bool = false,
        errorMessage: String? = nil,
        onCancel: @escaping () -> Void = {},
        onContinue: @escaping (String) -> Void = { _ in }
    ) {
        self.isDeleting = isDeleting
        self.errorMessage = errorMessage
        self.onCancel = onCancel
        self.onContinue = onContinue
    }

    public var body: some View {
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
                    isEnabled: canDelete,
                    action: { onContinue(password) }
                )
            }
        }
        .padding(24)
    }

    private var canDelete: Bool {
        password.count >= 8 && !isDeleting
    }
}

#Preview("회원탈퇴") {
    AccountDeletionView()
}
