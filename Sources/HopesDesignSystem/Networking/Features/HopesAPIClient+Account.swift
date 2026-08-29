import Foundation

public extension HopesAPIClient {
    func myPage() async throws -> UserResponse { try await authenticatedGet(path: "/api/mypage") }

    func updateMyPage(username: String?, nickname: String?, profileInfo: String?, profileImage: String? = nil) async throws -> UserResponse {
        try await request(path: "/api/mypage", method: "PATCH", body: MyPageUpdateRequest(username: username, nickname: nickname, profileInfo: profileInfo, profileImage: profileImage), requiresAuthentication: true)
    }

    func settings() async throws -> SettingMainResponse { try await authenticatedGet(path: "/api/setting/main") }

    func updateSettings(customPrompt: String?, deleteAllChats: Bool = false) async throws -> SettingMainResponse {
        try await request(path: "/api/setting", method: "PATCH", body: SettingUpdateRequest(customPrompt: customPrompt, deleteAllChats: deleteAllChats), requiresAuthentication: true)
    }

    func submitInquiry(content: String) async throws -> MessageEnvelope {
        try await request(path: "/api/setting/inquiry", method: "POST", body: InquiryRequest(content: content), requiresAuthentication: true)
    }

    func deleteMyAccount(password: String) async throws {
        try await requestNoContent(path: "/api/account", method: "DELETE", body: DeleteAccountRequest(password: password), requiresAuthentication: true, clearStoredTokenOnUnauthorized: false)
        try? await tokenStore.clear()
    }
}
