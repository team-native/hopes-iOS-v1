import SwiftUI

public struct HopesStatTile: View {
    private let value: String
    private let label: String
    private let tint: Color

    public init(
        value: String,
        label: String,
        tint: Color = .hopesBrandPrimary
    ) {
        self.value = value
        self.label = label
        self.tint = tint
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(Color.hopesTextSecondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 48)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius)
        )
        .overlay {
            RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius)
                .stroke(Color.hopesBorder, lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label), \(value)")
    }
}

#Preview("Hopes Stat Tiles") {
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
    .padding()
    .background(Color.hopesBackground)
}
