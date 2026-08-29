import Foundation

public extension HopesAPIClient {
    func main(searchKeyword: String? = nil, page: Int = 0, size: Int = 50) async throws -> MainResponse {
        guard var components = URLComponents(url: baseURL.appending(path: "/api/main"), resolvingAgainstBaseURL: false) else { throw HopesAPIError.invalidResponse }
        var queryItems = [URLQueryItem(name: "page", value: String(page)), URLQueryItem(name: "size", value: String(size))]
        if let searchKeyword, !searchKeyword.isEmpty { queryItems.append(URLQueryItem(name: "searchKeyword", value: searchKeyword)) }
        components.queryItems = queryItems
        guard let url = components.url else { throw HopesAPIError.invalidResponse }
        return try await request(url: url, method: "GET", body: nil, requiresAuthentication: true)
    }

    func createChat(title: String? = nil) async throws -> ChatResponse {
        try await request(path: "/api/chats", method: "POST", body: CreateChatRequest(title: title), requiresAuthentication: true)
    }

    func sendMessage(chatID: Int64, content: String) async throws -> ChatResponse {
        guard content.count <= 12_000 else { throw HopesAPIError.server(statusCode: 400, message: "질문은 12,000자 이하여야 합니다") }
        guard let url = URL(string: "/api/chats/\(chatID)/messages", relativeTo: baseURL) else { throw HopesAPIError.invalidResponse }
        return try await request(url: url, method: "POST", body: try encoder.encode(SendMessageRequest(content: content)), requiresAuthentication: true, timeoutInterval: 70)
    }

    func chat(id: Int64, messagePage: Int = 0, messageSize: Int = 50) async throws -> ChatResponse {
        guard var components = URLComponents(url: baseURL.appending(path: "/api/chats/\(id)"), resolvingAgainstBaseURL: false) else { throw HopesAPIError.invalidResponse }
        components.queryItems = [URLQueryItem(name: "messagePage", value: String(messagePage)), URLQueryItem(name: "messageSize", value: String(messageSize))]
        guard let url = components.url else { throw HopesAPIError.invalidResponse }
        return try await request(url: url, method: "GET", body: nil, requiresAuthentication: true)
    }
}
