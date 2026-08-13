import SwiftUI

public struct LoginFlowView: View {
    private enum Screen {
        case guide
        case login
        case signUp
        case onboarding
        case chatHome
        case chatDetail
        case answerEvidence
        case conversationHistory
        case myPage
        case settings
        case generalSettings
        case personalSettings
        case contact
        case accountInfo
    }

    @State private var screen: Screen
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggingIn = false
    @State private var loginErrorMessage: String?
    @State private var signUpEmail = ""
    @State private var name = ""
    @State private var major = ""
    @State private var cohort = ""
    @State private var chatMessage = ""
    @State private var chatReply = ""
    @State private var profileName = "임서하"
    @State private var profileIntroduction = ""

    private let onLogin: () -> Void
    private let onSignUp: (SignUpFormData) -> Void
    private let onStartChat: () -> Void

    public init(
        isLoginInitiallyOpen: Bool = false,
        isSignUpInitiallyOpen: Bool = false,
        isOnboardingInitiallyOpen: Bool = false,
        isChatHomeInitiallyOpen: Bool = false,
        isChatDetailInitiallyOpen: Bool = false,
        isAnswerEvidenceInitiallyOpen: Bool = false,
        isConversationHistoryInitiallyOpen: Bool = false,
        isMyPageInitiallyOpen: Bool = false,
        isSettingsInitiallyOpen: Bool = false,
        isGeneralSettingsInitiallyOpen: Bool = false,
        isPersonalSettingsInitiallyOpen: Bool = false,
        isContactInitiallyOpen: Bool = false,
        isAccountInfoInitiallyOpen: Bool = false,
        onLogin: @escaping () -> Void = {},
        onSignUp: @escaping (SignUpFormData) -> Void = { _ in },
        onStartChat: @escaping () -> Void = {}
    ) {
        let initialScreen: Screen = if isAccountInfoInitiallyOpen {
            .accountInfo
        } else if isContactInitiallyOpen {
            .contact
        } else if isPersonalSettingsInitiallyOpen {
            .personalSettings
        } else if isGeneralSettingsInitiallyOpen {
            .generalSettings
        } else if isSettingsInitiallyOpen {
            .settings
        } else if isMyPageInitiallyOpen {
            .myPage
        } else if isConversationHistoryInitiallyOpen {
            .conversationHistory
        } else if isAnswerEvidenceInitiallyOpen {
            .answerEvidence
        } else if isChatDetailInitiallyOpen {
            .chatDetail
        } else if isChatHomeInitiallyOpen {
            .chatHome
        } else if isOnboardingInitiallyOpen {
            .onboarding
        } else if isSignUpInitiallyOpen {
            .signUp
        } else if isLoginInitiallyOpen {
            .login
        } else {
            .guide
        }

        _screen = State(initialValue: initialScreen)
        self.onLogin = onLogin
        self.onSignUp = onSignUp
        self.onStartChat = onStartChat
    }

    public var body: some View {
        ZStack {
            switch screen {
            case .guide:
                LoginSwipeGuideView {
                    transition(to: .login)
                }
                .transition(.opacity)

            case .login:
                LoginView(
                    email: $email,
                    password: $password,
                    isLoading: isLoggingIn,
                    errorMessage: loginErrorMessage,
                    onLogin: {
                        login()
                    },
                    onSignUp: {
                        transition(to: .signUp)
                    }
                )
                .transition(.move(edge: .bottom))

            case .signUp:
                SignUpView(
                    email: $signUpEmail,
                    name: $name,
                    major: $major,
                    cohort: $cohort,
                    onSignUp: { data in
                        onSignUp(data)
                        transition(to: .onboarding)
                    },
                    onGoToLogin: {
                        transition(to: .login)
                    }
                )
                .transition(.move(edge: .trailing))

            case .onboarding:
                OnboardingView {
                    onStartChat()
                    transition(to: .chatHome)
                }
                    .transition(.move(edge: .trailing))

            case .chatHome:
                ChatHomeView(
                    message: $chatMessage,
                    onSend: { _ in
                        transition(to: .chatDetail)
                    },
                    onSelectTab: navigateFromTab
                )
                    .transition(.move(edge: .trailing))

            case .chatDetail:
                ChatDetailView(
                    reply: $chatReply,
                    onBack: {
                        transition(to: .chatHome)
                    },
                    onShowSources: {
                        transition(to: .answerEvidence)
                    },
                    onSelectTab: navigateFromTab
                )
                    .transition(.move(edge: .trailing))

            case .answerEvidence:
                AnswerEvidenceView(
                    onBack: {
                        transition(to: .chatDetail)
                    },
                    onAskMore: {
                        chatReply = "이 근거를 바탕으로 더 자세히 알려줘."
                        transition(to: .chatDetail)
                    },
                    onSelectTab: navigateFromTab
                )
                    .transition(.move(edge: .trailing))

            case .conversationHistory:
                ConversationHistoryView(
                    onNewConversation: {
                        chatMessage = ""
                        transition(to: .chatHome)
                    },
                    onSelectConversation: { _ in
                        transition(to: .chatDetail)
                    },
                    onSelectTab: navigateFromTab
                )
                    .transition(.move(edge: .trailing))

            case .myPage:
                MyPageView(
                    name: $profileName,
                    introduction: $profileIntroduction,
                    onBackToChat: {
                        transition(to: .settings)
                    },
                    onOpenAccountInfo: {
                        transition(to: .accountInfo)
                    },
                    onSelectTab: navigateFromTab
                )
                    .transition(.move(edge: .trailing))

            case .settings:
                SettingsView(
                    onBackToChat: {
                        transition(to: .chatHome)
                    },
                    onOpenGeneral: {
                        transition(to: .generalSettings)
                    },
                    onOpenPersonalSettings: {
                        transition(to: .personalSettings)
                    },
                    onOpenContact: {
                        transition(to: .contact)
                    },
                    onLogout: {
                        transition(to: .login)
                    },
                    onSelectTab: navigateFromTab
                )
                    .transition(.move(edge: .trailing))

            case .generalSettings:
                GeneralSettingsView(
                    onBack: {
                        transition(to: .settings)
                    },
                    onDone: {
                        transition(to: .settings)
                    },
                    onBackToChat: {
                        transition(to: .chatHome)
                    },
                    onSelectTab: navigateFromTab
                )
                    .transition(.move(edge: .trailing))

            case .personalSettings:
                PersonalSettingsView(
                    onBack: {
                        transition(to: .settings)
                    },
                    onDone: {
                        transition(to: .settings)
                    },
                    onBackToChat: {
                        transition(to: .chatHome)
                    },
                    onSelectTab: navigateFromTab
                )
                    .transition(.move(edge: .trailing))

            case .contact:
                ContactView(
                    onBack: {
                        transition(to: .settings)
                    },
                    onDone: {
                        transition(to: .settings)
                    },
                    onSend: { _, _ in
                        transition(to: .settings)
                    },
                    onSelectTab: navigateFromTab
                )
                    .transition(.move(edge: .trailing))

            case .accountInfo:
                AccountInfoView(
                    onBack: {
                        transition(to: .myPage)
                    },
                    onDone: {
                        transition(to: .myPage)
                    },
                    onSelectTab: navigateFromTab
                )
                    .transition(.move(edge: .trailing))
            }
        }
    }

    private func transition(to screen: Screen) {
        withAnimation(.spring(response: 0.42, dampingFraction: 0.88)) {
            self.screen = screen
        }
    }

    private func login() {
        guard !isLoggingIn else { return }
        isLoggingIn = true
        loginErrorMessage = nil

        Task {
            do {
                try await HopesAPIClient.shared.login(
                    username: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password
                )
                await MainActor.run {
                    isLoggingIn = false
                    password = ""
                    onLogin()
                    transition(to: .chatHome)
                }
            } catch {
                await MainActor.run {
                    isLoggingIn = false
                    loginErrorMessage = (error as? LocalizedError)?.errorDescription
                        ?? "로그인에 실패했습니다."
                }
            }
        }
    }

    private func navigateFromTab(_ tab: HopesTab) {
        switch tab {
        case .home:
            transition(to: .chatHome)
        case .chat:
            transition(to: .chatHome)
        case .history:
            transition(to: .conversationHistory)
        case .settings:
            transition(to: .myPage)
        }
    }
}

#Preview("로그인 플로우") {
    LoginFlowView()
        .frame(width: 402, height: 874)
}
