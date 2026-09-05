import SwiftUI

extension LoginFlowView {
    func restoreSession() {
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

    func handleAuthenticationFailure(_ error: Error) {
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

    func requestPasswordResetCode() {
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

    func resetPassword() {
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

    func completePasswordReset() {
        guard isPasswordResetVerified else { return }
        clearPasswordResetState()
        password = ""
        transition(to: .login)
    }

    func clearPasswordResetState() {
        isPasswordResetCodeRequested = false
        isPasswordResetVerified = false
        isResettingPassword = false
        passwordResetCode = ""
        passwordResetNewPassword = ""
        passwordResetErrorMessage = nil
    }

    func login() {
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
}
