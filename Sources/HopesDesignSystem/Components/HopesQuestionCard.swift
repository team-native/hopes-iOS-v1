import SwiftUI

public struct HopesQuestionCard<Icon: View>: View {
    private let title: String
    private let icon: Icon
    private let action: () -> Void

    public init(
        title: String,
        action: @escaping () -> Void,
        @ViewBuilder icon: () -> Icon
    ) {
        self.title = title
        self.action = action
        self.icon = icon()
    }

    public var body: some View {
        Button(action: action) {
            HopesCard(padding: 16) {
                HStack(spacing: 14) {
                    icon
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.hopesBrandPrimary)
                        .frame(width: 38, height: 38)
                        .background(Color.hopesBrandTint)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: HopesMetrics.smallCornerRadius
                            )
                        )

                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.hopesTextPrimary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(height: HopesMetrics.contentRowHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityHint("질문을 선택합니다")
    }
}

#Preview("Hopes Question Cards") {
    VStack(spacing: 14) {
        HopesQuestionCard(
            title: "기숙사 하루 일과가 어떻게 돼?",
            action: {}
        ) {
            Text("⌂")
        }

        HopesQuestionCard(
            title: "입학하려면 뭘 준비해야 해?",
            action: {}
        ) {
            Text("◇")
        }

        HopesQuestionCard(
            title: "전공 선택은 어떻게 하는 게 좋아?",
            action: {}
        ) {
            Text("<>")
        }

        HopesQuestionCard(
            title: "후배한테 해주고 싶은 조언 있어?",
            action: {}
        ) {
            Text("□")
        }
    }
    .padding()
    .background(Color.hopesBackground)
}
