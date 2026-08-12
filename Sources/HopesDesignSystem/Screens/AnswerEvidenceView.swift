import SwiftUI

public struct AnswerEvidenceView: View {
    public struct Evidence: Identifiable, Sendable {
        public let id: String
        public let title: String
        public let subtitle: String

        public init(title: String, subtitle: String) {
            id = title
            self.title = title
            self.subtitle = subtitle
        }
    }

    @State private var selectedTab: HopesTab = .chat

    private let evidenceItems: [Evidence]
    private let onBack: () -> Void
    private let onShare: () -> Void
    private let onOpenEvidence: (Evidence) -> Void
    private let onAskMore: () -> Void
    private let onSelectTab: (HopesTab) -> Void

    public init(
        evidenceItems: [Evidence] = [
            Evidence(title: "점호 시간", subtitle: "생활관 기본 루틴"),
            Evidence(title: "자습실 분위기", subtitle: "시험 기간 집중도"),
            Evidence(title: "빨래 루틴", subtitle: "요일별 관리 팁"),
        ],
        onBack: @escaping () -> Void = {},
        onShare: @escaping () -> Void = {},
        onOpenEvidence: @escaping (Evidence) -> Void = { _ in },
        onAskMore: @escaping () -> Void = {},
        onSelectTab: @escaping (HopesTab) -> Void = { _ in }
    ) {
        self.evidenceItems = evidenceItems
        self.onBack = onBack
        self.onShare = onShare
        self.onOpenEvidence = onOpenEvidence
        self.onAskMore = onAskMore
        self.onSelectTab = onSelectTab
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color.hopesBackground

            header
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 72)

            summaryCard
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 156)

            evidenceList
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 390)

            HopesButton(
                "이 근거로 더 물어보기",
                size: .large,
                action: onAskMore
            )
            .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
            .padding(.top, 684)

            HopesTabBar(selection: $selectedTab, onSelect: onSelectTab)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
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
            .accessibilityLabel("뒤로")

            VStack(alignment: .leading, spacing: 1) {
                Text("답변 근거")
                    .font(.system(size: 27, weight: .bold))
                    .foregroundStyle(Color.hopesTextPrimary)

                Text("선배 답변을 요약한 참고 정보예요.")
                    .font(.footnote)
                    .foregroundStyle(Color.hopesTextSecondary)
            }

            Spacer(minLength: 8)

            HopesButton(
                "공유",
                variant: .secondary,
                size: .small,
                width: .fixed(54),
                action: onShare
            )
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("기숙사 생활 핵심")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.hopesTextPrimary)

            Text("점호, 자습, 빨래, 시험 기간 생활 패턴을 기준으로 답변을 구성했어요.")
                .font(.subheadline)
                .foregroundStyle(Color.hopesTextSecondary)
                .lineSpacing(2)
                .padding(.top, 14)

            HStack(spacing: 12) {
                HopesStatTile(value: "6개", label: "근거")
                HopesStatTile(
                    value: "3명",
                    label: "선배",
                    tint: .hopesSuccess
                )
                HopesStatTile(
                    value: "2026",
                    label: "최신",
                    tint: .hopesWarning
                )
            }
            .padding(.top, 18)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 190)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius)
        )
        .overlay {
            RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius)
                .stroke(Color.hopesBorder, lineWidth: 1)
        }
    }

    private var evidenceList: some View {
        VStack(spacing: 16) {
            ForEach(evidenceItems) { evidence in
                evidenceRow(evidence)
            }
        }
    }

    private func evidenceRow(_ evidence: Evidence) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(evidence.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.hopesTextPrimary)

                Text(evidence.subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.hopesTextSecondary)
            }

            Spacer(minLength: 8)

            HopesButton(
                "보기",
                variant: .secondary,
                size: .compact,
                width: .fixed(52)
            ) {
                onOpenEvidence(evidence)
            }
        }
        .padding(.horizontal, 24)
        .frame(height: HopesMetrics.contentRowHeight)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.hopesBorder, lineWidth: 1)
        }
    }
}

#Preview("답변 근거") {
    AnswerEvidenceView()
        .frame(width: 402, height: 874)
}
