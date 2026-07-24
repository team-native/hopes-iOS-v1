import SwiftUI

public struct HopesActionRow: View {
    private let title: String
    private let subtitle: String
    private let actionTitle: String
    private let action: () -> Void

    public init(
        title: String,
        subtitle: String,
        actionTitle: String = "열기",
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.hopesTextPrimary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.hopesTextSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            HopesButton(
                actionTitle,
                variant: .secondary,
                size: .compact,
                width: .fit,
                action: action
            )
        }
        .padding(.horizontal, 20)
        .frame(height: HopesMetrics.rowHeight)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius)
        )
        .overlay {
            RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius)
                .stroke(Color.hopesBorder, lineWidth: 1)
        }
    }
}

#Preview("Hopes Action Rows") {
    VStack(spacing: 12) {
        HopesActionRow(
            title: "일반",
            subtitle: "다크 모드, 표시 방식"
        ) {}

        HopesActionRow(
            title: "개인 설정",
            subtitle: "시스템 프롬프트 관리"
        ) {}

        HopesActionRow(
            title: "문의하기",
            subtitle: "gsm-chatbot@gsm.hs.kr",
            actionTitle: "열기"
        ) {}

        HopesActionRow(
            title: "점호 시간",
            subtitle: "생활관 기본 루틴",
            actionTitle: "보기"
        ) {}
    }
    .padding()
    .background(Color.hopesBackground)
}
