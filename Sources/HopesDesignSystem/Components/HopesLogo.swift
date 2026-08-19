import SwiftUI
import UIKit

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
            logoImage

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

    @ViewBuilder
    private var logoImage: some View {
        if let image = appIconImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
        } else {
            Text("h")
                .font(.system(size: size == .compact ? 26 : 40, weight: .bold))
                .foregroundStyle(Color.hopesBrandPrimary)
                .frame(width: iconSize, height: iconSize)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: size == .compact ? 12 : 18))
        }
    }

    private var appIconImage: UIImage? {
        if let image = UIImage(named: "AppIcon60x60", in: .main, compatibleWith: nil) {
            return image
        }

        let iconURL = Bundle.main
            .urls(forResourcesWithExtension: "png", subdirectory: nil)?
            .first { $0.deletingPathExtension().lastPathComponent.hasPrefix("AppIcon60x60") }

        return iconURL.flatMap { UIImage(contentsOfFile: $0.path) }
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
