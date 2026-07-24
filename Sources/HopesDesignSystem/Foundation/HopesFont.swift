import CoreText
import Foundation
import SwiftUI

public enum HopesFontWeight: Sendable {
    case regular
    case semibold
    case bold

    fileprivate var postScriptName: String {
        switch self {
        case .regular:
            "Inter-Regular"
        case .semibold:
            "Inter-SemiBold"
        case .bold:
            "Inter-Bold"
        }
    }
}

public enum HopesTypography {
    public static func inter(
        size: CGFloat,
        weight: HopesFontWeight = .regular,
        relativeTo textStyle: Font.TextStyle = .body
    ) -> Font {
        HopesFontRegistration.registerIfNeeded()
        return .custom(weight.postScriptName, size: size, relativeTo: textStyle)
    }
}

public enum HopesFontRegistration {
    private static let registration: Void = {
        let fontURLs = Bundle.module.urls(
            forResourcesWithExtension: "otf",
            subdirectory: nil
        ) ?? []

        for url in fontURLs {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }()

    public static func registerIfNeeded() {
        _ = registration
    }
}
