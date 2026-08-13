import Foundation

public struct LoginRequest: Encodable, Sendable {
    public let username: String
    public let password: String

    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}

public struct TokenResponse: Decodable, Sendable, Equatable {
    public let accessToken: String
    public let tokenType: String
}

struct ServerMessage: Decodable {
    let message: String
}

public enum HopesAPIError: LocalizedError, Sendable, Equatable {
    case invalidResponse
    case unauthorized(String)
    case server(statusCode: Int, message: String)
    case transport(String)
    case decoding

    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "서버 응답을 확인할 수 없습니다."
        case let .unauthorized(message), let .server(_, message):
            message
        case .transport:
            "서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요."
        case .decoding:
            "서버 응답을 처리하지 못했습니다."
        }
    }
}
