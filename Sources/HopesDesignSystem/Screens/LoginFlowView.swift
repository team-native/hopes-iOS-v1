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
    @State private var profileEmail = ""
    @State private var profileMajor = ""
    @State private var isLoadingProfile = false
    @State private var isSavingProfile = false
    @State private var profileErrorMessage: String?
    @State private var customPrompt = ""
    @State private var isSavingSettings = false
    @State private var settingsErrorMessage: String?
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
                    onNewChat: {
                        startNewChat()
                    },
                    onSend: { message in
                        startNewChat(with: message)
                    },
                    onSelectTab: navigateFromTab
                )
                    .transition(.move(edge: .trailing))

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
                    .transition(.move(edge: .trailing))

            case .myPage:
                MyPageView(
                    name: $profileName,
                    introduction: $profileIntroduction,
                    email: profileEmail,
                    major: profileMajor,
                    isLoading: isLoadingProfile,
                    isSaving: isSavingProfile,
                    errorMessage: profileErrorMessage,
                    onBackToChat: {
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
                    onSelectTab: navigateFromTab
                )
                    .id(customPrompt)
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
        .task {
            if screen == .chatHome || screen == .conversationHistory {
                loadConversations()
            }
        }
    }

    private func transition(to screen: Screen) {
        withAnimation(.spring(response: 0.42, dampingFraction: 0.88)) {
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
                await MainActor.run { settingsErrorMessage = error.localizedDescription }
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
