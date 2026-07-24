import SwiftUI

public struct HopesCard<Content: View>: View {
    public enum Elevation: Sendable {
        case flat
        case raised
    }

    private let padding: CGFloat
    private let cornerRadius: CGFloat
    private let elevation: Elevation
    private let content: Content

    public init(
        padding: CGFloat = 24,
        cornerRadius: CGFloat = HopesMetrics.cardCornerRadius,
        elevation: Elevation = .raised,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.elevation = elevation
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .leading
            )
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.hopesBorder, lineWidth: 1)
            }
            .shadow(
                color: shadowColor,
                radius: elevation == .raised ? 8 : 0,
                y: elevation == .raised ? 6 : 0
            )
    }

    private var shadowColor: Color {
        guard elevation == .raised else {
            return .clear
        }

        return Color(
            red: 13 / 255,
            green: 26 / 255,
            blue: 46 / 255
        )
        .opacity(0.07)
    }
}

#Preview("Hopes Cards") {
    ScrollView {
        VStack(spacing: 20) {
            HopesCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("기숙사 생활 핵심")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.hopesTextPrimary)

                    Text("점호, 자습, 빨래, 시험 기간 생활 패턴을 기준으로 답변을 구성했어요.")
                        .font(.subheadline)
                        .foregroundStyle(Color.hopesTextSecondary)
                }
            }

            HopesCard(
                padding: 20,
                cornerRadius: HopesMetrics.controlCornerRadius,
                elevation: .flat
            ) {
                Text("그림자 없는 내부 카드")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.hopesTextPrimary)
            }

            HopesCard(padding: 12, cornerRadius: 16) {
                Text("작은 패딩 카드")
                    .font(.caption)
                    .foregroundStyle(Color.hopesTextSecondary)
            }
        }
        .padding()
    }
    .background(Color.hopesBackground)
}
