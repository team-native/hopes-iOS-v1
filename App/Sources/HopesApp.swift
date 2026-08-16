import HopesDesignSystem
import SwiftUI
import UIKit

@main
struct HopesApp: App {
    init() {
        // Keep the app's own color palette unchanged while ensuring every
        // UIKit-backed SwiftUI input uses the standard iOS light keyboard.
        UITextField.appearance().keyboardAppearance = .light
        UITextView.appearance().keyboardAppearance = .light
        UISearchBar.appearance().keyboardAppearance = .light
        UISearchTextField.appearance().keyboardAppearance = .light
    }

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
                isMyPageInitiallyOpen: ProcessInfo.processInfo.arguments.contains("--show-my-page"),
                isSettingsInitiallyOpen: ProcessInfo.processInfo.arguments.contains("--show-settings"),
                isGeneralSettingsInitiallyOpen: ProcessInfo.processInfo.arguments.contains("--show-general-settings"),
                isPersonalSettingsInitiallyOpen: ProcessInfo.processInfo.arguments.contains("--show-personal-settings"),
                isContactInitiallyOpen: ProcessInfo.processInfo.arguments.contains("--show-contact")
            )
        }
    }
}
