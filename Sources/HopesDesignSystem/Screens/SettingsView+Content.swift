import SwiftUI

extension SettingsView {
    var header: some View {
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

    var accountActions: some View {
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
                Divider().padding(.leading, 52)
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

    func accountActionRow(
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
                Text(title).font(.subheadline.weight(.semibold))
                Spacer()
                if isLoggingOut && title == "로그아웃 중..." {
                    ProgressView().controlSize(.small)
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
