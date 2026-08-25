import SwiftUI

public struct LoginFlowView: View {
    private enum Screen {
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

    @State private var screen: Screen
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggingIn = false
    @State private var loginErrorMessage: String?
    @State private var passwordResetCode = ""
    @State private var passwordResetNewPassword = ""
    @State private var isPasswordResetCodeRequested = false
    @State private var isPasswordResetVerified = false
    @State private var isResettingPassword = false
    @State private var passwordResetErrorMessage: String?
    @State private var signUpEmail = ""
    @State private var name = ""
    @State private var major = ""
    @State private var cohort = ""
    @State private var chatMessage = ""
    @State private var chatReply = ""
    @State private var profileName = "임서하"
    @State private var profileIntroduction = ""
    @State private var profileEmail = ""
    @State private var profileMajor = ""
    @State private var profileCohort = ""
    @State private var isLoadingProfile = false
    @State private var isSavingProfile = false
    @State private var profileErrorMessage: String?
    @State private var customPrompt = ""
    @State private var isSavingSettings = false
    @State private var settingsErrorMessage: String?
    @State private var isSendingInquiry = false
    @State private var inquiryErrorMessage: String?
    @State private var isLoggingOut = false
    @State private var isDeletingAccount = false
    @State private var accountDeletionErrorMessage: String?
    @State private var conversations: [ConversationHistoryView.Conversation] = []
    @State private var isLoadingConversations = false
    @State private var conversationErrorMessage: String?
    @State private var selectedConversationID: Int64?
    @State private var activeChat: ChatResponse?
    @State private var isLoadingChat = false
    @State private var isSendingMessage = false
    @State private var chatErrorMessage: String?

    private let onLogin: () -> Void
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
                    isDeletingAccount: isDeletingAccount,
                    accountDeletionErrorMessage: accountDeletionErrorMessage,
                    onBack: {
                        transition(to: .myPage)
                    },
                    onDone: {
                        transition(to: .myPage)
                    },
                    onDeleteAccount: deleteAccount,
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

    private func transition(to screen: Screen) {
        withAnimation(.easeOut(duration: 0.16)) {
            self.screen = screen
        }
        if screen == .chatHome || screen == .conversationHistory {
            loadConversations()
        } else if screen == .myPage {
            loadProfile()
        } else if screen == .settings || screen == .personalSettings {
            loadSettings()
        }
    }

    private func restoreSession() {
        Task {
            do {
                guard try await HopesAPIClient.shared.hasStoredAccessToken() else { return }
                let response = try await HopesAPIClient.shared.main()
                let mappedConversations = response.chatList.map { summary in
                    ConversationHistoryView.Conversation(
                        id: summary.id,
                        title: summary.title,
                        period: conversationPeriod(for: summary.updatedAt)
                    )
                }
                await MainActor.run {
                    conversations = mappedConversations
                    withAnimation(.easeOut(duration: 0.16)) {
                        screen = .onboarding
                    }
                }
            } catch {
                await MainActor.run {
                    handleAuthenticationFailure(error)
                }
            }
        }
    }

    private func handleAuthenticationFailure(_ error: Error) {
        guard let apiError = error as? HopesAPIError,
              case .unauthorized = apiError
        else { return }
        activeChat = nil
        selectedConversationID = nil
        conversations = []
        password = ""
        loginErrorMessage = "로그인이 만료되었습니다. 다시 로그인해주세요."
        transition(to: .login)
    }

    private func requestPasswordResetCode() {
        guard !isResettingPassword else { return }
        isResettingPassword = true
        isPasswordResetVerified = false
        passwordResetErrorMessage = nil
        Task {
            do {
                try await HopesAPIClient.shared.requestPasswordReset(email: email.trimmingCharacters(in: .whitespacesAndNewlines))
                await MainActor.run {
                    isResettingPassword = false
                    isPasswordResetCodeRequested = true
                }
            } catch {
                await MainActor.run {
                    isResettingPassword = false
                    passwordResetErrorMessage = error.localizedDescription
                }
            }
        }
    }

    private func resetPassword() {
        guard !isResettingPassword else { return }
        guard PasswordPolicy.isValid(passwordResetNewPassword) else {
            passwordResetErrorMessage = "비밀번호는 영문과 숫자를 포함해 8~15자로 입력해주세요."
            return
        }
        isResettingPassword = true
        passwordResetErrorMessage = nil
        Task {
            do {
                try await HopesAPIClient.shared.resetPassword(
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    code: passwordResetCode,
                    newPassword: passwordResetNewPassword
                )
                await MainActor.run {
                    isResettingPassword = false
                    isPasswordResetVerified = true
                }
            } catch {
                await MainActor.run {
                    isResettingPassword = false
                    passwordResetErrorMessage = error.localizedDescription
                }
            }
        }
    }

    private func completePasswordReset() {
        guard isPasswordResetVerified else { return }
        clearPasswordResetState()
        password = ""
        transition(to: .login)
    }

    private func clearPasswordResetState() {
        isPasswordResetCodeRequested = false
        isPasswordResetVerified = false
        isResettingPassword = false
        passwordResetCode = ""
        passwordResetNewPassword = ""
        passwordResetErrorMessage = nil
    }

    private func loadProfile() {
        guard !isLoadingProfile else { return }
        isLoadingProfile = true
        profileErrorMessage = nil
        Task {
            do {
                let profile = try await HopesAPIClient.shared.myPage()
                await MainActor.run {
                    apply(profile: profile)
                    isLoadingProfile = false
                }
            } catch {
                await MainActor.run {
                    handleAuthenticationFailure(error)
                    isLoadingProfile = false
                    profileErrorMessage = error.localizedDescription
                }
            }
        }
    }

    private func saveProfile(_ profile: MyPageView.Profile) {
        guard !isSavingProfile else { return }
        isSavingProfile = true
        profileErrorMessage = nil
        Task {
            do {
                let updated = try await HopesAPIClient.shared.updateMyPage(
                    username: profile.name,
                    nickname: nil,
                    profileInfo: profile.introduction
                )
                await MainActor.run {
                    apply(profile: updated)
                    isSavingProfile = false
                }
            } catch {
                await MainActor.run {
                    handleAuthenticationFailure(error)
                    isSavingProfile = false
                    profileErrorMessage = error.localizedDescription
                }
            }
        }
    }

    private func loadSettings() {
        Task {
            do {
                let settings = try await HopesAPIClient.shared.settings()
                await MainActor.run {
                    customPrompt = settings.customPrompt
                    apply(profile: settings.accountSetting)
                    settingsErrorMessage = nil
                }
            } catch {
                await MainActor.run {
                    handleAuthenticationFailure(error)
                    settingsErrorMessage = error.localizedDescription
                }
            }
        }
    }

    private func saveSettings(prompt: String) {
        guard !isSavingSettings else { return }
        isSavingSettings = true
        settingsErrorMessage = nil
        Task {
            do {
                let settings = try await HopesAPIClient.shared.updateSettings(customPrompt: prompt)
                await MainActor.run {
                    customPrompt = settings.customPrompt
                    isSavingSettings = false
                }
            } catch {
                await MainActor.run {
                    handleAuthenticationFailure(error)
                    isSavingSettings = false
                    settingsErrorMessage = error.localizedDescription
                }
            }
        }
    }

    private func deleteAllConversations() {
        guard !isSavingSettings else { return }
        isSavingSettings = true
        settingsErrorMessage = nil
        Task {
            do {
                let settings = try await HopesAPIClient.shared.updateSettings(
                    customPrompt: nil,
                    deleteAllChats: true
                )
                await MainActor.run {
                    customPrompt = settings.customPrompt
                    conversations = []
                    activeChat = nil
                    selectedConversationID = nil
                    isSavingSettings = false
                }
            } catch {
                await MainActor.run {
                    handleAuthenticationFailure(error)
                    isSavingSettings = false
                    settingsErrorMessage = error.localizedDescription
                }
            }
        }
    }

    private func apply(profile: UserResponse) {
        profileName = profile.username
        profileIntroduction = profile.profileInfo
        profileEmail = profile.email
        profileMajor = profile.major ?? "미설정"
        profileCohort = profile.cohort.map { "\($0)기" } ?? "미설정"
    }

    private func submitInquiry(content: String) {
        guard !isSendingInquiry else { return }
        isSendingInquiry = true
        inquiryErrorMessage = nil
        Task {
            do {
                _ = try await HopesAPIClient.shared.submitInquiry(content: content)
                await MainActor.run {
                    isSendingInquiry = false
                    transition(to: .settings)
                }
            } catch {
                await MainActor.run {
                    handleAuthenticationFailure(error)
                    isSendingInquiry = false
                    inquiryErrorMessage = error.localizedDescription
                }
            }
        }
    }

    private func logout() {
        guard !isLoggingOut else { return }
        isLoggingOut = true
        settingsErrorMessage = nil
        Task {
            do {
                _ = try await HopesAPIClient.shared.logout()
                await MainActor.run {
                    isLoggingOut = false
                    activeChat = nil
                    conversations = []
                    transition(to: .login)
                }
            } catch {
                await MainActor.run {
                    handleAuthenticationFailure(error)
                    isLoggingOut = false
                    settingsErrorMessage = error.localizedDescription
                }
            }
        }
    }

    private func deleteAccount(password: String) {
        guard !isDeletingAccount else { return }
        isDeletingAccount = true
        accountDeletionErrorMessage = nil
        Task {
            do {
                try await HopesAPIClient.shared.deleteMyAccount(password: password)
                await MainActor.run {
                    isDeletingAccount = false
                    activeChat = nil
                    conversations = []
                    selectedConversationID = nil
                    profileName = ""
                    profileIntroduction = ""
                    profileEmail = ""
                    profileMajor = ""
                    profileCohort = ""
                    self.password = ""
                    transition(to: .login)
                }
            } catch {
                await MainActor.run {
                    isDeletingAccount = false
                    accountDeletionErrorMessage = error.localizedDescription
                    settingsErrorMessage = "회원탈퇴에 실패했습니다. \(error.localizedDescription)"
                }
            }
        }
    }

    private func loadConversations(searchKeyword: String? = nil) {
        guard !isLoadingConversations else { return }
        isLoadingConversations = true
        conversationErrorMessage = nil
        Task {
            do {
                let response = try await HopesAPIClient.shared.main(searchKeyword: searchKeyword)
                let mappedConversations = response.chatList.map { summary in
                    ConversationHistoryView.Conversation(
                        id: summary.id,
                        title: summary.title,
                        period: conversationPeriod(for: summary.updatedAt)
                    )
                }
                await MainActor.run {
                    conversations = mappedConversations
                    isLoadingConversations = false
                }
            } catch {
                await MainActor.run {
                    handleAuthenticationFailure(error)
                    isLoadingConversations = false
                    conversationErrorMessage = error.localizedDescription
                }
            }
        }
    }

    private func startNewChat(with initialMessage: String? = nil) {
        guard !isLoadingChat else { return }
        isLoadingChat = true
        chatErrorMessage = nil
        activeChat = nil
        transition(to: .chatDetail)
        Task {
            do {
                let createdChat = try await HopesAPIClient.shared.createChat(title: nil)
                await MainActor.run {
                    activeChat = createdChat
                    selectedConversationID = createdChat.id
                    isLoadingChat = false
                }
                if let initialMessage, !initialMessage.isEmpty {
                    await MainActor.run { chatMessage = "" }
                    sendMessage(initialMessage)
                }
            } catch {
                await MainActor.run {
                    handleAuthenticationFailure(error)
                    isLoadingChat = false
                    chatErrorMessage = error.localizedDescription
                }
            }
        }
    }

    private func loadChat(id: Int64) {
        guard !isLoadingChat else { return }
        isLoadingChat = true
        chatErrorMessage = nil
        activeChat = nil
        Task {
            do {
                let chat = try await HopesAPIClient.shared.chat(id: id)
                await MainActor.run {
                    activeChat = chat
                    isLoadingChat = false
                }
            } catch {
                await MainActor.run {
                    handleAuthenticationFailure(error)
                    isLoadingChat = false
                    chatErrorMessage = error.localizedDescription
                }
            }
        }
    }

    private func sendMessage(_ content: String) {
        guard let chatID = activeChat?.id ?? selectedConversationID,
              !isSendingMessage
        else { return }
        isSendingMessage = true
        chatErrorMessage = nil
        Task {
            do {
                let updatedChat = try await HopesAPIClient.shared.sendMessage(
                    chatID: chatID,
                    content: content
                )
                await MainActor.run {
                    activeChat = updatedChat
                    selectedConversationID = updatedChat.id
                    isSendingMessage = false
                    loadConversations()
                }
            } catch {
                await MainActor.run {
                    handleAuthenticationFailure(error)
                    isSendingMessage = false
                    chatErrorMessage = error.localizedDescription
                }
            }
        }
    }

    private func conversationPeriod(for updatedAt: String) -> ConversationHistoryView.Conversation.Period {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = formatter.date(from: updatedAt)
            ?? ISO8601DateFormatter().date(from: updatedAt)
        guard let date else { return .older }
        return date >= Date().addingTimeInterval(-7 * 24 * 60 * 60) ? .recent : .older
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
                    transition(to: .onboarding)
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
            transition(to: .onboarding)
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
