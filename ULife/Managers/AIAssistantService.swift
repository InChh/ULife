import Foundation
import SwiftProtobuf

final class AIAssistantService {
    static let shared = AIAssistantService()
    private init() {}

    private let client = ProtoNetworkManager.shared

    private let chatEndpoint = "/v1/proto/ai/chat"
    private let historyEndpoint = "/v1/proto/ai/history"

    func chat(request: Campus_Ai_ChatRequest) async throws -> Campus_Ai_ChatResponse {
        try await client.requestProto(
            endpoint: chatEndpoint,
            method: .post,
            request: request
        )
    }

    func history(conversationId: Int64) async throws -> Campus_Ai_ChatHistoryResponse {
        let endpoint = "\(historyEndpoint)/\(conversationId)"
        let empty = Campus_Ai_ChatHistoryRequest()
        return try await client.requestProto(
            endpoint: endpoint,
            method: .get,
            request: empty
        )
    }
}
