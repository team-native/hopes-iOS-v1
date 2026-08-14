import SwiftUI

public struct SettingsView: View {
    @State private var selectedTab: HopesTab = .settings

    private let contactEmail: String
    private let onBackToChat: () -> Void
    private let onOpenGeneral: () -> Void
    private let onOpenPersonalSettings: () -> Void
    private let onOpenContact: () -> Void
    private let onLogout: () -> Void
    private let onSelectTab: (HopesTab) -> Void
    private let isLoggingOut: Bool
    private let errorMessage: String?

    public init(
        contactEmail: String = "gsm-chatbot@gsm.hs.kr",
        isLoggingOut: Bool = false,
        errorMessage: String? = nil,
        onBackToChat: @escaping () -> Void = {},
        onOpenGeneral: @escaping () -> Void = {},
        onOpenPersonalSettings: @escaping () -> Void = {},
        onOpenContact: @escaping () -> Void = {},
        onLogout: @escaping () -> Void = {},
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

            HopesButton(
                isLoggingOut ? "로그아웃 중..." : "로그아웃",
                variant: .danger,
                width: .fixed(330),
                isEnabled: !isLoggingOut,
                action: onLogout
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 29)
            .padding(.top, 307)

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(Color.hopesDanger)
                    .padding(.horizontal, 30)
                    .padding(.top, 365)
            }

            HopesTabBar(selection: $selectedTab, onSelect: onSelectTab)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()
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

}

#Preview("설정") {
    SettingsView()
        .frame(width: 402, height: 874)
}
