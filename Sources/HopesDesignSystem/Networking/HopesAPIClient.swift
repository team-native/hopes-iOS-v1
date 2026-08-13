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
        requiresAuthentication: Bool
    ) async throws -> Response {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20
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
