import HopesDesignSystem
import SwiftUI

@main
@MainActor
struct HopesApp: App {
    @State private var isSplashVisible = true

    var body: some Scene {
        WindowGroup {
            ZStack {
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

                if isSplashVisible {
                    HopesLaunchView()
                        .transition(.opacity)
                }
            }
            .task {
                try? await Task.sleep(for: .milliseconds(450))
                guard !Task.isCancelled else { return }
                withAnimation(.easeOut(duration: 0.18)) {
                    isSplashVisible = false
                }
            }
        }
    }
}

private struct HopesLaunchView: View {
    var body: some View {
        Color.hopesBackground
            .ignoresSafeArea()
            .overlay {
                Image("AppIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
            }
    }
}
