import SwiftUI
import Testing
@testable import HopesDesignSystem

@Test
func logoMetricsMatchFigma() {
    #expect(HopesMetrics.smallCornerRadius == 12)
}

@Test
@MainActor
func logoCanBeConstructed() {
    _ = HopesLogo()
    _ = HopesLogo(placement: .onBrand)
    _ = HopesLogo(size: .large)
}

@Test
@MainActor
func buttonVariantsCanBeConstructed() {
    _ = HopesButton("Primary") {}
    _ = HopesButton(
        "Secondary",
        variant: .secondary,
        size: .compact,
        width: .fit
    ) {}
    _ = HopesButton("Danger", variant: .danger) {}
    _ = HopesButton("Disabled", isEnabled: false) {}
}

@Test
@MainActor
func cardVariantsCanBeConstructed() {
    _ = HopesCard { Text("Raised") }
    _ = HopesCard(
        padding: 20,
        cornerRadius: HopesMetrics.controlCornerRadius,
        elevation: .flat
    ) {
        Text("Flat")
    }
}
