import SwiftUI

public extension Color {
    static let hopesBackground = Color("HopesBackground", bundle: .module)
    static let hopesBrandPrimary = Color("HopesBrandPrimary", bundle: .module)
    static let hopesBrandTint = Color("HopesBrandTint", bundle: .module)
    static let hopesBorder = Color("HopesBorder", bundle: .module)
    static let hopesInputBackground = Color("HopesInputBackground", bundle: .module)

    static let hopesTextPrimary = Color("HopesTextPrimary", bundle: .module)
    static let hopesTextSecondary = Color("HopesTextSecondary", bundle: .module)
    static let hopesTextPlaceholder = Color("HopesTextPlaceholder", bundle: .module)

    static let hopesDanger = Color("HopesDanger", bundle: .module)
    static let hopesDangerSurface = Color("HopesDangerSurface", bundle: .module)
    static let hopesSuccess = Color("HopesSuccess", bundle: .module)
    static let hopesWarning = Color("HopesWarning", bundle: .module)

    static let hopesHeroGradient = LinearGradient(
        colors: [
            Color("HopesGradientTop", bundle: .module),
            Color("HopesGradientBottom", bundle: .module),
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}
