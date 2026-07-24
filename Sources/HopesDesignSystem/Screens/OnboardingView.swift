import SwiftUI

public struct OnboardingView: View {
    @State private var selectedTab: HopesTab = .home

    private let onStartChat: () -> Void

    public init(onStartChat: @escaping () -> Void = {}) {
        self.onStartChat = onStartChat
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color.hopesHeroGradient

            HopesLogo(placement: .onBrand)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 32)
                .padding(.top, 76)

            Text("선배 답변을\n더 정확하게 받는 방법")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 32)
                .padding(.top, 220)

            Text("질문에 학년, 관심 전공, 상황을 같이 적으면 더\n현실적인 답변을 받을 수 있어요.")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color("HopesBlueSecondaryText", bundle: .module))
                .lineSpacing(5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 32)
                .padding(.top, 330)

            tipCard(
                "1. “기숙사 어때?”보다 “1학년 기숙사 평일 루틴\n알려줘”"
            )
            .padding(.top, 450)

            tipCard(
                "2. 입학/전공/학교생활 중 카테고리를 먼저 골라\n요."
            )
            .padding(.top, 546)

            HopesButton(
                "채팅 시작하기",
                variant: .dark,
                size: .extraLarge,
                width: .fixed(338),
                action: onStartChat
            )
            .padding(.top, 706)

            HopesTabBar(selection: $selectedTab)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()
    }

    private func tipCard(_ text: String) -> some View {
        HopesCard(
            padding: 0,
            cornerRadius: HopesMetrics.cardCornerRadius,
            elevation: .flat
        ) {
            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.hopesTextPrimary)
                .lineSpacing(2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 22)
                .padding(.top, 24)
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(width: 338, height: 78)
    }
}

#Preview("온보딩") {
    OnboardingView()
        .frame(width: 402, height: 874)
}
