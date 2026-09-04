import SwiftUI

extension LoginFlowView {
    func loadProfile() {
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

    func saveProfile(_ profile: MyPageView.Profile) {
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

    func loadSettings() {
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

    func saveSettings(prompt: String) {
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

    func deleteAllConversations() {
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

    func apply(profile: UserResponse) {
        profileName = profile.username
        profileIntroduction = profile.profileInfo
        profileEmail = profile.email
        profileMajor = profile.major ?? "미설정"
        profileCohort = profile.cohort.map { "\($0)기" } ?? "미설정"
    }

    func submitInquiry(content: String) {
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

    func logout() {
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

    func deleteAccount(password: String) {
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
}
