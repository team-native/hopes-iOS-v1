import SwiftUI

public struct PersonalSettingsView: View {
    @State private var selectedTab: HopesTab = .settings
    @State private var systemPrompt: String
    @State private var showsDeleteConfirmation = false

    private let onBack: () -> Void
    private let onDone: () -> Void
    private let onBackToChat: () -> Void
    private let onSavePrompt: (String) -> Void
    private let onDeleteAllConversations: () -> Void
    private let onSelectTab: (HopesTab) -> Void
    private let isSaving: Bool
    private let errorMessage: String?

    public init(
        systemPrompt: String = "",
        isSaving: Bool = false,
        errorMessage: String? = nil,
        onBack: @escaping () -> Void = {},
        onDone: @escaping () -> Void = {},
        onBackToChat: @escaping () -> Void = {},
        onSavePrompt: @escaping (String) -> Void = { _ in },
        onDeleteAllConversations: @escaping () -> Void = {},
        onSelectTab: @escaping (HopesTab) -> Void = { _ in }
    ) {
        _systemPrompt = State(initialValue: systemPrompt)
        self.isSaving = isSaving
        self.errorMessage = errorMessage
        self.onBack = onBack
        self.onDone = onDone
        self.onBackToChat = onBackToChat
        self.onSavePrompt = onSavePrompt
        self.onDeleteAllConversations = onDeleteAllConversations
        self.onSelectTab = onSelectTab
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

            HopesButton(
                "전체 대화 삭제",
                variant: .danger,
                isEnabled: !isSaving
            ) {
                showsDeleteConfirmation = true
            }
            .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
            .padding(.top, 590)

            HopesTabBar(selection: $selectedTab, onSelect: onSelectTab)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()
        .confirmationDialog(
            "모든 대화를 삭제할까요?",
            isPresented: $showsDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("전체 대화 삭제", role: .destructive, action: onDeleteAllConversations)
            Button("취소", role: .cancel) {}
        } message: {
            Text("서버에 저장된 모든 대화가 삭제되며 되돌릴 수 없습니다.")
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

                HopesButton(
                    isSaving ? "저장 중" : "프롬프트 저장",
                    size: .regular,
                    width: .fixed(100)
                ) {
                    onSavePrompt(systemPrompt)
                }
                .disabled(isSaving)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, 19)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(Color.hopesDanger)
                        .padding(.top, 10)
                }
            }
        }
        .frame(height: 408)
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
        .frame(height: 210)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius)
                .stroke(Color.hopesBorder, lineWidth: 1)
        }
    }

}

#Preview("개인 설정") {
    PersonalSettingsView()
        .frame(width: 402, height: 874)
}
