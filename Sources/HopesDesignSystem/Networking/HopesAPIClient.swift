import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public actor HopesAPIClient {
    public static let productionBaseURL: URL = {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "service.gsmsv.site"
        components.port = 22116
        guard let url = components.url else {
            preconditionFailure("Invalid production API URL components")
        }
        return url
    }()
    public static let shared = HopesAPIClient()

    private let baseURL: URL
    private let session: URLSession
    private let tokenStore: AccessTokenStore
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(
        baseURL: URL = HopesAPIClient.productionBaseURL,
        session: URLSession = .shared,
        tokenStore: AccessTokenStore = AccessTokenStore()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.tokenStore = tokenStore
    }

    @discardableResult
    public func login(username: String, password: String) async throws -> TokenResponse {
        let response: TokenResponse = try await request(
            path: "/api/login",
            method: "POST",
            body: LoginRequest(username: username, password: password),
            requiresAuthentication: false
        )
        try await tokenStore.save(response.accessToken)
        return response
    }

    @discardableResult
    public func requestEmailVerification(email: String) async throws -> MessageEnvelope {
        try await request(
            path: "/api/signup/email-verifications",
            method: "POST",
            body: EmailVerificationRequest(email: email),
            requiresAuthentication: false
        )
    }

    @discardableResult
    public func confirmEmailVerification(email: String, code: String) async throws -> MessageEnvelope {
        try await request(
            path: "/api/signup/email-verifications/confirm",
            method: "POST",
            body: EmailVerificationConfirmRequest(email: email, code: code),
            requiresAuthentication: false
        )
    }

    @discardableResult
    public func requestPasswordReset(email: String) async throws -> MessageEnvelope {
        try await request(
            path: "/api/password/request",
            method: "POST",
            body: PasswordResetRequest(email: email),
            requiresAuthentication: false
        )
    }

    @discardableResult
    public func resetPassword(email: String, code: String, newPassword: String) async throws -> MessageEnvelope {
        try await request(
            path: "/api/password/reset",
            method: "POST",
            body: PasswordResetConfirmRequest(email: email, code: code, newPassword: newPassword),
            requiresAuthentication: false
        )
    }

    @discardableResult
    public func signUp(_ signupRequest: SignupRequest) async throws -> TokenResponse {
        let response: TokenResponse = try await request(
            path: "/api/signup",
            method: "POST",
            body: signupRequest,
            requiresAuthentication: false
        )
        try await tokenStore.save(response.accessToken)
        return response
    }

    public func main(
        searchKeyword: String? = nil,
        page: Int = 0,
        size: Int = 50
    ) async throws -> MainResponse {
        guard var components = URLComponents(
            url: baseURL.appending(path: "/api/main"),
            resolvingAgainstBaseURL: false
        ) else {
            throw HopesAPIError.invalidResponse
        }
        var queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "size", value: String(size)),
        ]
        if let searchKeyword, !searchKeyword.isEmpty {
            queryItems.append(URLQueryItem(name: "searchKeyword", value: searchKeyword))
        }
        components.queryItems = queryItems
        guard let url = components.url else {
            throw HopesAPIError.invalidResponse
        }
        return try await request(url: url, method: "GET", body: nil, requiresAuthentication: true)
    }

    public func createChat(title: String? = nil) async throws -> ChatResponse {
        try await request(
            path: "/api/chats",
            method: "POST",
            body: CreateChatRequest(title: title),
            requiresAuthentication: true
        )
    }

    public func sendMessage(chatID: Int64, content: String) async throws -> ChatResponse {
        guard content.count <= 12_000 else {
            throw HopesAPIError.server(statusCode: 400, message: "질문은 12,000자 이하여야 합니다")
        }
        guard let url = URL(string: "/api/chats/\(chatID)/messages", relativeTo: baseURL) else {
            throw HopesAPIError.invalidResponse
        }
        return try await request(
            url: url,
            method: "POST",
            body: try encoder.encode(SendMessageRequest(content: content)),
            requiresAuthentication: true,
            timeoutInterval: 70
        )
    }

    public func chat(id: Int64, messagePage: Int = 0, messageSize: Int = 50) async throws -> ChatResponse {
        guard var components = URLComponents(
            url: baseURL.appending(path: "/api/chats/\(id)"),
            resolvingAgainstBaseURL: false
        ) else {
            throw HopesAPIError.invalidResponse
        }
        components.queryItems = [
            URLQueryItem(name: "messagePage", value: String(messagePage)),
            URLQueryItem(name: "messageSize", value: String(messageSize)),
        ]
        guard let url = components.url else {
            throw HopesAPIError.invalidResponse
        }
        return try await request(url: url, method: "GET", body: nil, requiresAuthentication: true)
    }

    public func myPage() async throws -> UserResponse {
        try await authenticatedGet(path: "/api/mypage")
    }

    public func updateMyPage(
        username: String?,
        nickname: String?,
        profileInfo: String?,
        profileImage: String? = nil
    ) async throws -> UserResponse {
        try await request(
            path: "/api/mypage",
            method: "PATCH",
            body: MyPageUpdateRequest(
                username: username,
                nickname: nickname,
                profileInfo: profileInfo,
                profileImage: profileImage
            ),
            requiresAuthentication: true
        )
    }

    public func settings() async throws -> SettingMainResponse {
        try await authenticatedGet(path: "/api/setting/main")
    }

    public func updateSettings(
        customPrompt: String?,
        deleteAllChats: Bool = false
    ) async throws -> SettingMainResponse {
        try await request(
            path: "/api/setting",
            method: "PATCH",
            body: SettingUpdateRequest(customPrompt: customPrompt, deleteAllChats: deleteAllChats),
            requiresAuthentication: true
        )
    }

    public func submitInquiry(content: String) async throws -> MessageEnvelope {
        try await request(
            path: "/api/setting/inquiry",
            method: "POST",
            body: InquiryRequest(content: content),
            requiresAuthentication: true
        )
    }

    public func logout() async throws -> MessageEnvelope {
        let response: MessageEnvelope = try await request(
            path: "/api/logout",
            method: "POST",
            body: EmptyRequest(),
            requiresAuthentication: true
        )
        try await tokenStore.clear()
        return response
    }

    private func authenticatedGet<Response: Decodable>(path: String) async throws -> Response {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw HopesAPIError.invalidResponse
        }
        return try await request(url: url, method: "GET", body: nil, requiresAuthentication: true)
    }

    private func request<Response: Decodable, Body: Encodable>(
        path: String,
        method: String,
        body: Body,
        requiresAuthentication: Bool
    ) async throws -> Response {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw HopesAPIError.invalidResponse
        }

        return try await request(
            url: url,
            method: method,
            body: try encoder.encode(body),
            requiresAuthentication: requiresAuthentication
        )
    }

    private func request<Response: Decodable>(
        url: URL,
        method: String,
        body: Data?,
        requiresAuthentication: Bool,
        timeoutInterval: TimeInterval = 20
    ) async throws -> Response {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = timeoutInterval
        request.httpBody = body

        if requiresAuthentication {
            guard let token = try await tokenStore.token() else {
                throw HopesAPIError.unauthorized("로그인이 필요합니다")
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw HopesAPIError.transport(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HopesAPIError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let message = (try? decoder.decode(MessageEnvelope.self, from: data).message)
                ?? "요청을 처리하지 못했습니다."
            if httpResponse.statusCode == 401 {
                throw HopesAPIError.unauthorized(message)
            }
            throw HopesAPIError.server(statusCode: httpResponse.statusCode, message: message)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw HopesAPIError.decoding
        }
    }
}

private struct EmptyRequest: Encodable {}
