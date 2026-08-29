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
        guard let url = components.url else { preconditionFailure("Invalid production API URL components") }
        return url
    }()
    public static let shared = HopesAPIClient()

    let baseURL: URL
    let session: URLSession
    let tokenStore: AccessTokenStore
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    public init(baseURL: URL = HopesAPIClient.productionBaseURL, session: URLSession = .shared, tokenStore: AccessTokenStore = AccessTokenStore()) {
        self.baseURL = baseURL
        self.session = session
        self.tokenStore = tokenStore
    }

    public func hasStoredAccessToken() async throws -> Bool {
        try await tokenStore.token() != nil
    }

    func authenticatedGet<Response: Decodable>(path: String) async throws -> Response {
        guard let url = URL(string: path, relativeTo: baseURL) else { throw HopesAPIError.invalidResponse }
        return try await request(url: url, method: "GET", body: nil, requiresAuthentication: true)
    }

    func request<Response: Decodable, Body: Encodable>(path: String, method: String, body: Body, requiresAuthentication: Bool) async throws -> Response {
        guard let url = URL(string: path, relativeTo: baseURL) else { throw HopesAPIError.invalidResponse }
        return try await request(url: url, method: method, body: try encoder.encode(body), requiresAuthentication: requiresAuthentication)
    }

    func request<Response: Decodable>(url: URL, method: String, body: Data?, requiresAuthentication: Bool, timeoutInterval: TimeInterval = 20) async throws -> Response {
        let data = try await perform(
            url: url,
            method: method,
            body: body,
            requiresAuthentication: requiresAuthentication,
            timeoutInterval: timeoutInterval
        )
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw HopesAPIError.decoding
        }
    }

    func requestNoContent<Body: Encodable>(path: String, method: String, body: Body, requiresAuthentication: Bool, clearStoredTokenOnUnauthorized: Bool = true) async throws {
        guard let url = URL(string: path, relativeTo: baseURL) else { throw HopesAPIError.invalidResponse }
        _ = try await perform(
            url: url,
            method: method,
            body: try encoder.encode(body),
            requiresAuthentication: requiresAuthentication,
            timeoutInterval: 20,
            clearStoredTokenOnUnauthorized: clearStoredTokenOnUnauthorized
        )
    }

    private func perform(url: URL, method: String, body: Data?, requiresAuthentication: Bool, timeoutInterval: TimeInterval, clearStoredTokenOnUnauthorized: Bool = true) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = timeoutInterval
        request.httpBody = body

        if requiresAuthentication {
            guard let token = try await tokenStore.token() else { throw HopesAPIError.unauthorized("로그인이 필요합니다") }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw HopesAPIError.transport(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else { throw HopesAPIError.invalidResponse }
        guard 200..<300 ~= httpResponse.statusCode else {
            let message = serverMessage(from: data)
            if httpResponse.statusCode == 401 {
                if clearStoredTokenOnUnauthorized { try? await tokenStore.clear() }
                throw HopesAPIError.unauthorized(message)
            }
            throw HopesAPIError.server(statusCode: httpResponse.statusCode, message: message)
        }
        return data
    }

    private func serverMessage(from data: Data) -> String {
        if let message = try? decoder.decode(MessageEnvelope.self, from: data).message { return message }
        if let response = try? decoder.decode(ServerErrorEnvelope.self, from: data) { return response.error.message }
        return "요청을 처리하지 못했습니다."
    }
}

struct EmptyRequest: Encodable {}

private struct ServerErrorEnvelope: Decodable {
    let error: Detail

    struct Detail: Decodable {
        let message: String
    }
}
