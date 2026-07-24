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

@Test
@MainActor
func labeledTextFieldVariantsCanBeConstructed() {
    _ = HopesLabeledTextField(
        "이메일",
        text: .constant("s20000@gsm.hs.kr"),
        placeholder: "학교 이메일"
    )
    _ = HopesLabeledTextField(
        "비밀번호",
        text: .constant(""),
        placeholder: "비밀번호",
        isSecure: true
    )
    _ = HopesLabeledTextField(
        "비활성 입력",
        text: .constant("수정할 수 없어요"),
        isEnabled: false
    )
}
