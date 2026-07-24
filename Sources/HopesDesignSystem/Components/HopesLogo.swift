import SwiftUI

public struct HopesLogo: View {
    public enum Placement: Sendable {
        case onLight
        case onBrand
    }

    public enum Size: Sendable {
        case compact
        case large
    }

    private let placement: Placement
    private let size: Size
    private let schoolName: String

    public init(
        placement: Placement = .onLight,
        size: Size = .compact,
        schoolName: String = "광주소프트웨어마이스터고"
    ) {
        self.placement = placement
        self.size = size
        self.schoolName = schoolName
    }

    public var body: some View {
        HStack(spacing: size == .compact ? 12 : 0) {
            Text("h")
                .font(.system(size: iconFontSize, weight: .bold))
                .foregroundStyle(Color.hopesBrandPrimary)
                .frame(width: iconSize, height: iconSize)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: iconCornerRadius))

            if size == .compact {
                VStack(alignment: .leading, spacing: 0) {
                    Text("hopes")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(primaryTextColor)

                    Text(schoolName)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(secondaryTextColor)
                        .lineLimit(1)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("hopes, \(schoolName)")
    }

    private var iconSize: CGFloat {
        size == .compact ? 42 : 74
    }

    private var iconFontSize: CGFloat {
        size == .compact ? 26 : 40
    }

    private var iconCornerRadius: CGFloat {
        size == .compact ? 12 : 18
    }

    private var primaryTextColor: Color {
        placement == .onLight ? .hopesTextPrimary : .white
    }

    private var secondaryTextColor: Color {
        placement == .onLight
            ? .hopesTextSecondary
            : Color("HopesBlueSecondaryText", bundle: .module)
    }
}

#Preview("Hopes Logo") {
    VStack(alignment: .leading, spacing: 32) {
        HopesLogo()

        HopesLogo(placement: .onBrand)
            .padding()
            .background(Color.hopesHeroGradient)
            .clipShape(RoundedRectangle(cornerRadius: 16))

        HopesLogo(size: .large)
    }
    .padding()
    .background(Color.hopesBackground)
}
