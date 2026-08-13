import Foundation

public enum PasswordPolicy {
    public static let pattern = #"^(?=.*[A-Za-z])(?=.*\d).{8,15}$"#

    public static func isValid(_ password: String) -> Bool {
        password.range(of: pattern, options: .regularExpression) != nil
    }
}

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

    public init(accessToken: String, tokenType: String) {
        self.accessToken = accessToken
        self.tokenType = tokenType
    }
}

public struct MessageEnvelope: Decodable, Sendable, Equatable {
    public let message: String
}

public struct EmailVerificationRequest: Encodable, Sendable {
    public let email: String
}

public struct EmailVerificationConfirmRequest: Encodable, Sendable {
    public let email: String
    public let code: String
}

public struct SignupRequest: Encodable, Sendable {
    public let email: String
    public let username: String
    public let password: String
    public let passwordConfirm: String
    public let verificationCode: String
    public let gender: String?
    public let major: String?
    public let cohort: Int?
}

public struct ChatSummary: Decodable, Sendable, Equatable, Identifiable {
    public let id: Int64
    public let title: String
    public let updatedAt: String
}

public struct MainResponse: Decodable, Sendable, Equatable {
    public let chatList: [ChatSummary]
    public let newChat: Bool
    public let searchKeyword: String?
    public let page: Int
    public let size: Int
    public let hasNext: Bool
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
