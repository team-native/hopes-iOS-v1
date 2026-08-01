import HopesDesignSystem
import SwiftUI

@main
struct HopesApp: App {
    var body: some Scene {
        WindowGroup {
            LoginFlowView(
                isLoginInitiallyOpen: ProcessInfo.processInfo.arguments.contains("--show-login"),
                isSignUpInitiallyOpen: ProcessInfo.processInfo.arguments.contains("--show-sign-up"),
                isOnboardingInitiallyOpen: ProcessInfo.processInfo.arguments.contains("--show-onboarding"),
                isChatHomeInitiallyOpen: ProcessInfo.processInfo.arguments.contains("--show-chat-home"),
                isChatDetailInitiallyOpen: ProcessInfo.processInfo.arguments.contains("--show-chat-detail"),
                isAnswerEvidenceInitiallyOpen: ProcessInfo.processInfo.arguments.contains("--show-answer-evidence"),
                isConversationHistoryInitiallyOpen: ProcessInfo.processInfo.arguments.contains("--show-conversation-history"),
                isNotificationsInitiallyOpen: ProcessInfo.processInfo.arguments.contains("--show-notifications"),
                isMyPageInitiallyOpen: ProcessInfo.processInfo.arguments.contains("--show-my-page"),
                isSettingsInitiallyOpen: ProcessInfo.processInfo.arguments.contains("--show-settings"),
                isGeneralSettingsInitiallyOpen: ProcessInfo.processInfo.arguments.contains("--show-general-settings"),
                isPersonalSettingsInitiallyOpen: ProcessInfo.processInfo.arguments.contains("--show-personal-settings")
            )
        }
    }
}
