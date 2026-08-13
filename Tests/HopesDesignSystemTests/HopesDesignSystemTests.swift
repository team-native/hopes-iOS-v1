import SwiftUI
import Testing
@testable import HopesDesignSystem

@Test
func tokenResponseMatchesServerPayload() throws {
    let payload = Data(#"{"accessToken":"server-token","tokenType":"Bearer"}"#.utf8)
    let response = try JSONDecoder().decode(TokenResponse.self, from: payload)

    #expect(response == TokenResponse(accessToken: "server-token", tokenType: "Bearer"))
}

@Test
func serverErrorsExposeUserFacingMessages() {
    let error = HopesAPIError.unauthorized("등록된 회원을 찾을 수 없습니다.")

    #expect(error.errorDescription == "등록된 회원을 찾을 수 없습니다.")
}

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
    _ = HopesButton(
        "Fixed",
        size: .medium,
        width: .fixed(66)
    ) {}
    _ = HopesButton("Danger", variant: .danger) {}
    _ = HopesButton("Dark", variant: .dark, size: .extraLarge) {}
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

@Test
@MainActor
func actionRowVariantsCanBeConstructed() {
    _ = HopesActionRow(
        title: "일반",
        subtitle: "다크 모드, 표시 방식"
    ) {}
    _ = HopesActionRow(
        title: "점호 시간",
        subtitle: "생활관 기본 루틴",
        actionTitle: "보기"
    ) {}
}

@Test
@MainActor
func questionCardCanBeConstructed() {
    _ = HopesQuestionCard(
        title: "기숙사 하루 일과가 어떻게 돼?",
        action: {}
    ) {
        Text("⌂")
    }
}

@Test
@MainActor
func statTileVariantsCanBeConstructed() {
    _ = HopesStatTile(value: "6개", label: "근거")
    _ = HopesStatTile(
        value: "3명",
        label: "선배",
        tint: .hopesSuccess
    )
    _ = HopesStatTile(
        value: "2026",
        label: "최신",
        tint: .hopesWarning
    )
}

@Test
@MainActor
func toastVariantsCanBeConstructed() {
    _ = HopesToast("문의: gsm-chatbot@gsm.hs.kr")
    _ = HopesToast("프로필이 저장되었습니다.", accent: .hopesSuccess)
    _ = HopesToast("요청을 처리하지 못했습니다.", accent: .hopesDanger)
}

@Test
@MainActor
func settingsViewCanBeConstructed() {
    _ = SettingsView()
    _ = LoginFlowView(isSettingsInitiallyOpen: true)
}

@Test
@MainActor
func generalSettingsViewCanBeConstructed() {
    _ = GeneralSettingsView()
    _ = GeneralSettingsView(isDarkModeEnabled: true)
    _ = LoginFlowView(isGeneralSettingsInitiallyOpen: true)
}

@Test
@MainActor
func personalSettingsViewCanBeConstructed() {
    _ = PersonalSettingsView()
    _ = PersonalSettingsView(systemPrompt: "답변을 짧게 해줘.")
    _ = LoginFlowView(isPersonalSettingsInitiallyOpen: true)
}

@Test
@MainActor
func contactViewCanBeConstructed() {
    _ = ContactView()
    _ = ContactView(email: "student@gsm.hs.kr", message: "문의 내용")
    _ = LoginFlowView(isContactInitiallyOpen: true)
}

@Test
@MainActor
func loginSwipeGuideCanBeConstructed() {
    _ = LoginSwipeGuideView()
    _ = LoginSwipeGuideView(onOpenLogin: {})
}

@Test
@MainActor
func loginViewsCanBeConstructed() {
    _ = LoginView(
        email: .constant(""),
        password: .constant("")
    )
    _ = LoginFlowView()
    _ = LoginFlowView(isLoginInitiallyOpen: true)
    _ = LoginFlowView(isSignUpInitiallyOpen: true)
    _ = LoginFlowView(isOnboardingInitiallyOpen: true)
}

@Test
@MainActor
func signUpViewCanBeConstructed() {
    _ = SignUpView(
        email: .constant("s26055@gsm.hs.kr"),
        name: .constant("임서하"),
        major: .constant("소프트웨어개발과"),
        cohort: .constant("10기")
    )
}

@Test
@MainActor
func onboardingViewCanBeConstructed() {
    _ = OnboardingView()
    _ = OnboardingView(onStartChat: {})
    _ = HopesTabBar(selection: .constant(.home))
}

@Test
@MainActor
func chatHomeViewCanBeConstructed() {
    _ = ChatHomeView(message: .constant(""))
    _ = ChatHomeView(
        message: .constant("기숙사 하루 일과가 어떻게 돼?"),
        onNewChat: {},
        onSend: { _ in }
    )
    _ = LoginFlowView(isChatHomeInitiallyOpen: true)
}

@Test
@MainActor
func chatDetailViewCanBeConstructed() {
    _ = ChatDetailView(reply: .constant(""))
    _ = ChatDetailView(
        reply: .constant("점호는 몇 시야?"),
        onBack: {},
        onShowSources: {},
        onSend: { _ in },
        onShare: {}
    )
    _ = LoginFlowView(isChatDetailInitiallyOpen: true)
}

@Test
@MainActor
func answerEvidenceViewCanBeConstructed() {
    _ = AnswerEvidenceView()
    _ = AnswerEvidenceView(
        evidenceItems: [
            .init(title: "점호 시간", subtitle: "생활관 기본 루틴"),
        ],
        onBack: {},
        onShare: {},
        onOpenEvidence: { _ in },
        onAskMore: {}
    )
    _ = LoginFlowView(isAnswerEvidenceInitiallyOpen: true)
}

@Test
@MainActor
func conversationHistoryViewCanBeConstructed() {
    _ = ConversationHistoryView()
    _ = ConversationHistoryView(
        conversations: [
            .init(title: "기숙사 생활", period: .recent),
        ],
        onNewConversation: {},
        onSelectConversation: { _ in }
    )
    _ = LoginFlowView(isConversationHistoryInitiallyOpen: true)
}

@Test
@MainActor
func myPageViewCanBeConstructed() {
    _ = MyPageView(
        name: .constant("임서하"),
        introduction: .constant("")
    )
    _ = MyPageView(
        name: .constant("임서하"),
        introduction: .constant("프론트엔드에 관심이 많아요."),
        onBackToChat: {},
        onSave: { _ in }
    )
    _ = LoginFlowView(isMyPageInitiallyOpen: true)
}
