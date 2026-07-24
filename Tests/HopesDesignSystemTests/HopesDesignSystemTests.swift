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
