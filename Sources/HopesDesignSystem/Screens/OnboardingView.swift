import SwiftUI

public struct OnboardingView: View {
    @State private var selectedTab: HopesTab = .home

    private let onStartChat: () -> Void
    private let onSelectTab: (HopesTab) -> Void

    public init(
        onStartChat: @escaping () -> Void = {},
        onSelectTab: @escaping (HopesTab) -> Void = { _ in }
    ) {
        self.onStartChat = onStartChat
        self.onSelectTab = onSelectTab
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                HopesLogo(placement: .onBrand)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 32)
                    .padding(.top, 76)

                Text("선배 답변을\n더 정확하게 받는 방법")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)
                    .lineSpacing(3)
                    .padding(.horizontal, 32)
                    .padding(.top, 88)

                Text("질문에 학년, 관심 전공, 상황을 같이 적으면 더 현실적인 답변을 받을 수 있어요.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color("HopesBlueSecondaryText", bundle: .module))
                    .lineSpacing(5)
                    .frame(maxWidth: 306, alignment: .leading)
                    .padding(.horizontal, 32)
                    .padding(.top, 26)

                VStack(spacing: 15) {
                    tipCard(
                        number: "1",
                        caption: "“기숙사 어때” 보단,",
                        detail: "“1학년 기숙사 평일 루틴 알려줘”"
                    )

                    tipCard(
                        number: "2",
                        caption: "질문 전에,",
                        detail: "입학 / 전공 / 학교생활 중 카테고리를 골라요."
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 56)

                HopesButton(
                    "채팅 시작하기",
                    variant: .secondary,
                    size: .regular,
                    width: .fixed(338),
                    action: onStartChat
                )
                .frame(maxWidth: .infinity)
                .padding(.top, 84)
                .padding(.bottom, 38)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HopesTabBar(selection: $selectedTab, onSelect: onSelectTab)
        }
        .background(Color.hopesHeroGradient.ignoresSafeArea())
    }

    private func tipCard(number: String, caption: String, detail: String) -> some View {
        HopesCard(
            padding: 0,
            cornerRadius: HopesMetrics.cardCornerRadius,
            elevation: .flat
        ) {
            HStack(alignment: .top, spacing: 12) {
                Text(number)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(red: 10 / 255, green: 90 / 255, blue: 150 / 255))
                    .frame(width: 24, height: 24)
                    .background(Color.hopesBrandTint)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 12) {
                    Text(caption)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.hopesTextSecondary)

                    Text(detail)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.hopesTextPrimary)
                        .lineLimit(2)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(width: 338, height: 78)
    }
}

#Preview("온보딩") {
    OnboardingView()
        .frame(width: 402, height: 874)
}
