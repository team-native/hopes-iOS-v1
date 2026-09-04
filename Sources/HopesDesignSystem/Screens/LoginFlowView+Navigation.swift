import SwiftUI

extension LoginFlowView {
    func transition(to screen: Screen) {
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

    func navigateFromTab(_ tab: HopesTab) {
        switch tab {
        case .home:
            transition(to: .onboarding)
        case .chat:
            if shouldRestoreActiveChat,
               activeChat != nil || selectedConversationID != nil || isLoadingChat {
                transition(to: .chatDetail)
            } else {
                transition(to: .chatHome)
            }
        case .history:
            transition(to: .conversationHistory)
        case .settings:
            transition(to: .myPage)
        }
    }
}
