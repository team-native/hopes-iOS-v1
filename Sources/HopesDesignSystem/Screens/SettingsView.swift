import SwiftUI

public struct SettingsView: View {
    @State private var selectedTab: HopesTab = .settings

    private let contactEmail: String
    private let onBackToChat: () -> Void
    private let onOpenGeneral: () -> Void
    private let onOpenPersonalSettings: () -> Void
    private let onOpenContact: () -> Void
    private let onLogout: () -> Void

    public init(
        contactEmail: String = "gsm-chatbot@gsm.hs.kr",
        onBackToChat: @escaping () -> Void = {},
        onOpenGeneral: @escaping () -> Void = {},
        onOpenPersonalSettings: @escaping () -> Void = {},
        onOpenContact: @escaping () -> Void = {},
        onLogout: @escaping () -> Void = {}
    ) {
        self.contactEmail = contactEmail
        self.onBackToChat = onBackToChat
        self.onOpenGeneral = onOpenGeneral
        self.onOpenPersonalSettings = onOpenPersonalSettings
        self.onOpenContact = onOpenContact
        self.onLogout = onLogout
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color.hopesBackground

            header
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 76)

            settingsCard
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 172)

            HopesToast("문의: \(contactEmail)")
                .padding(.horizontal, 44)
                .padding(.top, 536)

            HopesTabBar(selection: $selectedTab)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("설정")
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color.hopesTextPrimary)

                Text("앱 설정과 도움말을 관리해요.")
                    .font(.footnote)
                    .foregroundStyle(Color.hopesTextSecondary)
            }

            Spacer()

            HopesButton(
                "채팅으로",
                variant: .secondary,
                size: .small,
                width: .fixed(54),
                action: onBackToChat
            )
        }
    }

    private var settingsCard: some View {
        HopesCard(padding: 20) {
            VStack(spacing: 12) {
                HopesActionRow(
                    title: "일반",
                    subtitle: "다크 모드, 표시 방식",
                    action: onOpenGeneral
                )

                HopesActionRow(
                    title: "개인 설정",
                    subtitle: "시스템 프롬프트 관리",
                    action: onOpenPersonalSettings
                )

                HopesActionRow(
                    title: "문의하기",
                    subtitle: contactEmail,
                    action: onOpenContact
                )

                HopesButton(
                    "로그아웃",
                    variant: .danger,
                    size: .regular,
                    action: onLogout
                )
            }
        }
        .frame(height: 317)
    }
}

#Preview("설정") {
    SettingsView()
        .frame(width: 402, height: 874)
}
