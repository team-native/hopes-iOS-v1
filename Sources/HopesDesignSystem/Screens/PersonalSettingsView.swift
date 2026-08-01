import SwiftUI

public struct PersonalSettingsView: View {
    @State private var selectedTab: HopesTab = .settings
    @State private var systemPrompt: String

    private let onBack: () -> Void
    private let onDone: () -> Void
    private let onBackToChat: () -> Void
    private let onSavePrompt: (String) -> Void
    private let onDeleteAllConversations: () -> Void

    public init(
        systemPrompt: String = "",
        onBack: @escaping () -> Void = {},
        onDone: @escaping () -> Void = {},
        onBackToChat: @escaping () -> Void = {},
        onSavePrompt: @escaping (String) -> Void = { _ in },
        onDeleteAllConversations: @escaping () -> Void = {}
    ) {
        _systemPrompt = State(initialValue: systemPrompt)
        self.onBack = onBack
        self.onDone = onDone
        self.onBackToChat = onBackToChat
        self.onSavePrompt = onSavePrompt
        self.onDeleteAllConversations = onDeleteAllConversations
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color.hopesBackground

            header
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 72)

            promptCard
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 158)

            backToChatRow
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 562)

            HopesTabBar(selection: $selectedTab)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()
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
            .accessibilityLabel("설정으로 돌아가기")

            VStack(alignment: .leading, spacing: 2) {
                Text("개인 설정")
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color.hopesTextPrimary)

                Text("AI 답변 스타일을 관리해요.")
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

    private var promptCard: some View {
        HopesCard(padding: 24) {
            VStack(alignment: .leading, spacing: 0) {
                Text("개인 설정")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.hopesTextPrimary)

                Text("시스템 프롬프트 (AI 응답 생성 시 반영됩니다)")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.hopesTextPrimary)
                    .padding(.top, 27)

                promptEditor
                    .padding(.top, 16)

                HStack(spacing: 14) {
                    HopesButton(
                        "프롬프트 저장",
                        size: .regular,
                        width: .fixed(134)
                    ) {
                        onSavePrompt(systemPrompt)
                    }

                    HopesButton(
                        "모든 대화 삭제",
                        variant: .danger,
                        size: .regular,
                        width: .fixed(126),
                        action: onDeleteAllConversations
                    )
                }
                .padding(.top, 28)
            }
        }
        .frame(height: 360)
    }

    private var promptEditor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $systemPrompt)
                .font(.subheadline)
                .foregroundStyle(Color.hopesTextPrimary)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 11)
                .padding(.vertical, 13)

            if systemPrompt.isEmpty {
                Text("예: 답변은 항상 3문장 이내로 짧게 해줘.")
                    .font(.subheadline)
                    .foregroundStyle(Color.hopesTextSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .allowsHitTesting(false)
            }
        }
        .frame(height: 136)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius)
                .stroke(Color.hopesBorder, lineWidth: 1)
        }
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
        .padding(.horizontal, 20)
        .frame(height: 72)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius)
                .stroke(Color.hopesBorder, lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.045), radius: 7, y: 4)
    }
}

#Preview("개인 설정") {
    PersonalSettingsView()
        .frame(width: 402, height: 874)
}
