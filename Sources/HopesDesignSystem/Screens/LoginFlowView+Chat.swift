import Foundation

extension LoginFlowView {
    func loadConversations(searchKeyword: String? = nil) {
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

    func startNewChat(with initialMessage: String? = nil) {
        guard !isLoadingChat else { return }
        isLoadingChat = true
        chatErrorMessage = nil
        activeChat = nil
        shouldRestoreActiveChat = true
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

    func loadChat(id: Int64) {
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

    func sendMessage(_ content: String) {
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

    func conversationPeriod(for updatedAt: String) -> ConversationHistoryView.Conversation.Period {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = formatter.date(from: updatedAt)
            ?? ISO8601DateFormatter().date(from: updatedAt)
        guard let date else { return .older }
        return date >= Date().addingTimeInterval(-7 * 24 * 60 * 60) ? .recent : .older
    }
}
