import SwiftUI

public struct GeneralSettingsView: View {
    @State private var selectedTab: HopesTab = .settings
    @State private var isDarkModeEnabled: Bool
    @State private var savedDarkModeEnabled: Bool

    private let onBack: () -> Void
    private let onDone: () -> Void
    private let onBackToChat: () -> Void
    private let onSave: (Bool) -> Void
    private let onSelectTab: (HopesTab) -> Void

    public init(
        isDarkModeEnabled: Bool = false,
        onBack: @escaping () -> Void = {},
        onDone: @escaping () -> Void = {},
        onBackToChat: @escaping () -> Void = {},
        onSave: @escaping (Bool) -> Void = { _ in },
        onSelectTab: @escaping (HopesTab) -> Void = { _ in }
    ) {
        _isDarkModeEnabled = State(initialValue: isDarkModeEnabled)
        _savedDarkModeEnabled = State(initialValue: isDarkModeEnabled)
        self.onBack = onBack
        self.onDone = onDone
        self.onBackToChat = onBackToChat
        self.onSave = onSave
        self.onSelectTab = onSelectTab
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color.hopesBackground

            header
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 72)

            generalCard
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 158)

            actionButtons
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 688)

            HopesTabBar(selection: $selectedTab, onSelect: onSelectTab)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.hopesTextPrimary)
                    .frame(width: 38, height: 38)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .overlay {
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(Color.hopesBorder, lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("설정으로 돌아가기")

            VStack(alignment: .leading, spacing: 2) {
                Text("일반 설정")
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color.hopesTextPrimary)

                Text("기본 앱 동작을 조정해요.")
                    .font(.footnote)
                    .foregroundStyle(Color.hopesTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HopesButton(
                "완료",
                variant: .secondary,
                size: .small,
                width: .fixed(54),
                action: complete
            )
        }
    }

    private var generalCard: some View {
        HopesCard(padding: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("일반")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.hopesTextPrimary)
                    .padding(.leading, 24)
                    .padding(.top, 28)

                darkModeRow
                    .padding(.horizontal, 10)
                    .padding(.top, 28)

                backToChatRow
                    .padding(.horizontal, 10)
                    .padding(.top, 16)
            }
        }
        .frame(height: 270)
    }

    private var darkModeRow: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 5) {
                Text("다크 모드")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.hopesTextPrimary)

                Text("시스템 설정에 맞춰 전환")
                    .font(.caption)
                    .foregroundStyle(Color.hopesTextSecondary)
            }

            Spacer()

            Toggle("다크 모드", isOn: $isDarkModeEnabled)
                .labelsHidden()
                .tint(.hopesBrandPrimary)
        }
        .padding(.horizontal, 20)
        .frame(height: 78)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.hopesBorder, lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.045), radius: 7, y: 4)
    }

    private var backToChatRow: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 5) {
                Text("뒤로")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.hopesTextPrimary)

                Text("채팅 화면으로 돌아가기")
                    .font(.caption)
                    .foregroundStyle(Color.hopesTextSecondary)
            }

            Spacer()

            HopesButton(
                "이동",
                variant: .secondary,
                size: .compact,
                width: .fixed(56),
                action: onBackToChat
            )
        }
        .padding(.horizontal, 19)
        .frame(height: 72)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.hopesBorder, lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.045), radius: 7, y: 4)
    }

    private var actionButtons: some View {
        HStack(spacing: 14) {
            HopesButton(
                "저장",
                size: .regular,
                width: .fixed(170),
                action: save
            )

            HopesButton(
                "초기화",
                variant: .secondary,
                size: .regular,
                width: .fixed(170),
                action: reset
            )
        }
    }

    private func save() {
        savedDarkModeEnabled = isDarkModeEnabled
        onSave(isDarkModeEnabled)
    }

    private func reset() {
        isDarkModeEnabled = false
    }

    private func complete() {
        if savedDarkModeEnabled != isDarkModeEnabled {
            save()
        }
        onDone()
    }
}

#Preview("일반 설정") {
    GeneralSettingsView()
        .frame(width: 402, height: 874)
}
