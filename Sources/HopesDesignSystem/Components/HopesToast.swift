import SwiftUI

public struct HopesToast: View {
    private let message: String
    private let accent: Color

    public init(
        _ message: String,
        accent: Color = .hopesBrandPrimary
    ) {
        self.message = message
        self.accent = accent
    }

    public var body: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(accent)
                .frame(width: 4)

            Text(message)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.hopesTextPrimary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, 20)
        }
        .frame(height: 58)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius)
        )
        .overlay {
            RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius)
                .stroke(Color.hopesBorder, lineWidth: 1)
        }
        .shadow(
            color: Color(
                red: 13 / 255,
                green: 26 / 255,
                blue: 46 / 255
            )
            .opacity(0.07),
            radius: 8,
            y: 6
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(message)
    }
}

#Preview("Hopes Toasts") {
    VStack(spacing: 20) {
        HopesToast("문의: gsm-chatbot@gsm.hs.kr")
        HopesToast("프로필이 저장되었습니다.", accent: .hopesSuccess)
        HopesToast("요청을 처리하지 못했습니다.", accent: .hopesDanger)
    }
    .padding()
    .background(Color.hopesBackground)
}
