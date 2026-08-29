import Foundation

public extension HopesAPIClient {
    @discardableResult
    func login(username: String, password: String) async throws -> TokenResponse {
        let response: TokenResponse = try await request(path: "/api/login", method: "POST", body: LoginRequest(username: username, password: password), requiresAuthentication: false)
        try await tokenStore.save(response.accessToken)
        return response
    }

    @discardableResult
    func requestEmailVerification(email: String) async throws -> MessageEnvelope {
        try await request(path: "/api/signup/email-verifications", method: "POST", body: EmailVerificationRequest(email: email), requiresAuthentication: false)
    }

    @discardableResult
    func confirmEmailVerification(email: String, code: String) async throws -> MessageEnvelope {
        try await request(path: "/api/signup/email-verifications/confirm", method: "POST", body: EmailVerificationConfirmRequest(email: email, code: code), requiresAuthentication: false)
    }

    @discardableResult
    func requestPasswordReset(email: String) async throws -> MessageEnvelope {
        try await request(path: "/api/password/request", method: "POST", body: PasswordResetRequest(email: email), requiresAuthentication: false)
    }

    @discardableResult
    func resetPassword(email: String, code: String, newPassword: String) async throws -> MessageEnvelope {
        try await request(path: "/api/password/reset", method: "POST", body: PasswordResetConfirmRequest(email: email, code: code, newPassword: newPassword), requiresAuthentication: false)
    }

    @discardableResult
    func signUp(_ signupRequest: SignupRequest) async throws -> TokenResponse {
        let response: TokenResponse = try await request(path: "/api/signup", method: "POST", body: signupRequest, requiresAuthentication: false)
        try await tokenStore.save(response.accessToken)
        return response
    }

    func logout() async throws -> MessageEnvelope {
        let response: MessageEnvelope = try await request(path: "/api/logout", method: "POST", body: EmptyRequest(), requiresAuthentication: true)
        try await tokenStore.clear()
        return response
    }
}
