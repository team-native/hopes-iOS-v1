import SwiftUI

public struct LoginFlowView: View {
    enum Screen {
        case guide
        case login
        case passwordReset
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

    @State var screen: Screen
    @State var email = ""
    @State var password = ""
    @State var isLoggingIn = false
    @State var loginErrorMessage: String?
    @State var passwordResetCode = ""
    @State var passwordResetNewPassword = ""
    @State var isPasswordResetCodeRequested = false
    @State var isPasswordResetVerified = false
    @State var isResettingPassword = false
    @State var passwordResetErrorMessage: String?
    @State var signUpEmail = ""
    @State var name = ""
    @State var major = ""
    @State var cohort = ""
    @State var chatMessage = ""
    @State var chatReply = ""
    @State var profileName = "임서하"
    @State var profileIntroduction = ""
    @State var profileEmail = ""
    @State var profileMajor = ""
    @State var profileCohort = ""
    @State var isLoadingProfile = false
    @State var isSavingProfile = false
    @State var profileErrorMessage: String?
    @State var customPrompt = ""
    @State var isSavingSettings = false
    @State var settingsErrorMessage: String?
    @State var isSendingInquiry = false
    @State var inquiryErrorMessage: String?
    @State var isLoggingOut = false
    @State var isDeletingAccount = false
    @State var accountDeletionErrorMessage: String?
    @State var conversations: [ConversationHistoryView.Conversation] = []
    @State var isLoadingConversations = false
    @State var conversationErrorMessage: String?
    @State var selectedConversationID: Int64?
    @State var activeChat: ChatResponse?
    @State var shouldRestoreActiveChat = false
    @State var isLoadingChat = false
    @State var isSendingMessage = false
    @State var chatErrorMessage: String?

    let onLogin: () -> Void
    private let onSignUp: (SignUpFormData) -> Void
    private let onStartChat: () -> Void
    private let restoresSessionOnLaunch: Bool

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
        restoresSessionOnLaunch = initialScreen == .guide
        self.onLogin = onLogin
        self.onSignUp = onSignUp
        self.onStartChat = onStartChat
    }

    public var body: some View {
        ZStack {
            switch screen {
            case .guide:
                loginView(isInitiallyExpanded: false)
                .transition(.opacity)

            case .login:
                loginView(isInitiallyExpanded: true)
                .transition(.opacity)

            case .passwordReset:
                PasswordResetView(
                    email: $email,
                    code: $passwordResetCode,
                    newPassword: $passwordResetNewPassword,
                    codeRequested: isPasswordResetCodeRequested,
                    isVerified: isPasswordResetVerified,
                    isLoading: isResettingPassword,
                    errorMessage: passwordResetErrorMessage,
                    onBack: {
                        clearPasswordResetState()
                        transition(to: .login)
                    },
                    onRequestCode: requestPasswordResetCode,
                    onReset: resetPassword,
                    onComplete: completePasswordReset
                )
                .transition(.opacity)

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
                .transition(.opacity)

            case .onboarding:
                OnboardingView(
                    onStartChat: {
                        onStartChat()
                        transition(to: .chatHome)
                    },
                    onSelectTab: navigateFromTab
                )
                    .transition(.opacity)

            case .chatHome:
                ChatHomeView(
                    message: $chatMessage,
                    onNewChat: {
                        startNewChat()
                    },
                    onSend: { message in
                        startNewChat(with: message)
                    },
                    onSelectTab: navigateFromTab
                )
                    .transition(.opacity)

            case .chatDetail:
                ChatDetailView(
                    reply: $chatReply,
                    title: activeChat?.title ?? "새 대화",
                    messages: activeChat?.messages ?? [],
                    isLoading: isLoadingChat,
                    isSending: isSendingMessage,
                    errorMessage: chatErrorMessage,
                    onBack: {
                        shouldRestoreActiveChat = false
                        transition(to: .chatHome)
                    },
                    onShowSources: {
                        transition(to: .answerEvidence)
                    },
                    onSend: { message in
                        sendMessage(message)
                    },
                    onSelectTab: navigateFromTab
                )
                    .transition(.opacity)

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
                    .transition(.opacity)

            case .conversationHistory:
                ConversationHistoryView(
                    conversations: conversations,
                    isLoading: isLoadingConversations,
                    errorMessage: conversationErrorMessage,
                    onNewConversation: {
                        chatMessage = ""
                        startNewChat()
                    },
                    onSelectConversation: { conversation in
                        selectedConversationID = conversation.id
                        shouldRestoreActiveChat = true
                        transition(to: .chatDetail)
                        loadChat(id: conversation.id)
                    },
                    onSearch: { searchKeyword in
                        loadConversations(searchKeyword: searchKeyword)
                    },
                    onSelectTab: navigateFromTab
                )
                    .transition(.opacity)

            case .myPage:
                MyPageView(
                    name: $profileName,
                    introduction: $profileIntroduction,
                    email: profileEmail,
                    major: profileMajor,
                    isLoading: isLoadingProfile,
                    isSaving: isSavingProfile,
                    errorMessage: profileErrorMessage,
                    onBack: {
                        transition(to: .chatHome)
                    },
                    onOpenSettings: {
                        transition(to: .settings)
                    },
                    onSave: { profile in
                        saveProfile(profile)
                    },
                    onOpenAccountInfo: {
                        transition(to: .accountInfo)
                    },
                    onSelectTab: navigateFromTab
                )
                    .transition(.opacity)

            case .settings:
                SettingsView(
                    isLoggingOut: isLoggingOut,
                    errorMessage: settingsErrorMessage,
                    onBackToChat: {
                        transition(to: .myPage)
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
                        logout()
                    },
                    isDeletingAccount: isDeletingAccount,
                    accountDeletionErrorMessage: accountDeletionErrorMessage,
                    onDeleteAccount: deleteAccount,
                    onSelectTab: navigateFromTab
                )
                    .transition(.opacity)

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
                    .transition(.opacity)

            case .personalSettings:
                PersonalSettingsView(
                    systemPrompt: customPrompt,
                    isSaving: isSavingSettings,
                    errorMessage: settingsErrorMessage,
                    onBack: {
                        transition(to: .settings)
                    },
                    onDone: {
                        transition(to: .settings)
                    },
                    onBackToChat: {
                        transition(to: .chatHome)
                    },
                    onSavePrompt: { prompt in
                        saveSettings(prompt: prompt)
                    },
                    onDeleteAllConversations: deleteAllConversations,
                    onSelectTab: navigateFromTab
                )
                    .id(customPrompt)
                    .transition(.opacity)

            case .contact:
                ContactView(
                    email: profileEmail,
                    isSending: isSendingInquiry,
                    errorMessage: inquiryErrorMessage,
                    onBack: {
                        transition(to: .settings)
                    },
                    onDone: {
                        transition(to: .settings)
                    },
                    onSend: { _, content in
                        submitInquiry(content: content)
                    },
                    onSelectTab: navigateFromTab
                )
                    .transition(.opacity)

            case .accountInfo:
                AccountInfoView(
                    email: profileEmail,
                    major: profileMajor,
                    cohort: profileCohort,
                    onBack: {
                        transition(to: .myPage)
                    },
                    onDone: {
                        transition(to: .myPage)
                    },
                    onSelectTab: navigateFromTab
                )
                    .transition(.opacity)
            }
        }
        .task {
            if restoresSessionOnLaunch && screen == .guide {
                restoreSession()
            } else if screen == .chatHome || screen == .conversationHistory {
                loadConversations()
            }
        }
    }

    @ViewBuilder
    private func loginView(isInitiallyExpanded: Bool) -> some View {
        LoginView(
            email: $email,
            password: $password,
            isLoading: isLoggingIn,
            errorMessage: loginErrorMessage,
            isInitiallyExpanded: isInitiallyExpanded,
            onLogin: {
                login()
            },
            onSignUp: {
                transition(to: .signUp)
            },
            onForgotPassword: {
                transition(to: .passwordReset)
            }
        )
    }

}

#Preview("로그인 플로우") {
    LoginFlowView()
        .frame(width: 402, height: 874)
}
