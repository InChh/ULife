//
//  ProtoNetworkManager.swift
//  ULife
//
//  Protobuf 网络请求管理器

import Foundation
import SwiftProtobuf

// MARK: - Protobuf Network Manager
class ProtoNetworkManager {
    static let shared = ProtoNetworkManager()
    
    private let session: URLSession
    private var authToken: String?
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = APIConfig.timeout
        config.timeoutIntervalForResource = APIConfig.timeout
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Token Management
    func setAuthToken(_ token: String) {
        self.authToken = token
    }
    
    func clearAuthToken() {
        self.authToken = nil
    }
    
    // MARK: - Protobuf Request
    func requestProto<RequestType: SwiftProtobuf.Message, ResponseType: SwiftProtobuf.Message>(
        endpoint: String,
        method: HTTPMethod = .post,
        request: RequestType? = nil,
        retryOnNetworkLoss: Bool = true
    ) async throws -> ResponseType {
        // Build URL
        let urlString = APIConfig.baseURL + endpoint
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        // Create request
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue("application/x-protobuf", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/x-protobuf", forHTTPHeaderField: "Accept")
        
        // Add auth token if available
        if let token = authToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add request body (protobuf binary)
        if let request = request {
            do {
                urlRequest.httpBody = try request.serializedData()
                print("📤 Protobuf Request: \(endpoint)")
                print("   Body size: \(urlRequest.httpBody?.count ?? 0) bytes")
            } catch {
                throw NetworkError.unknown(error)
            }
        }
        
        // Perform request
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            // Check HTTP status
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.noData
            }
            
            print("📥 Protobuf Response [\(httpResponse.statusCode)]")
            print("   Data size: \(data.count) bytes")
            
            // Handle non-200 status codes with server message fallback
            if !(200...299).contains(httpResponse.statusCode) {
                let serverMessage = String(data: data, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                throw NetworkError.serverError(
                    httpResponse.statusCode,
                    serverMessage?.isEmpty == false ? serverMessage! : "Server error"
                )
            }
            
            // Decode protobuf response
            do {
                let responseMessage = try ResponseType(serializedBytes: data)
                print("✅ Protobuf decoded successfully")
                return responseMessage
            } catch {
                print("❌ Protobuf decoding error: \(error)")
                throw NetworkError.decodingError(error)
            }
            
        } catch let error as NetworkError {
            throw error
        } catch {
            // 针对网络连接中断（-1005）做一次轻量重试
            if retryOnNetworkLoss,
               let urlError = error as? URLError,
               urlError.code == .networkConnectionLost {
                print("⚠️ Network connection lost, retrying once...")
                try await Task.sleep(nanoseconds: 300_000_000) // 0.3s
                return try await requestProto(
                    endpoint: endpoint,
                    method: method,
                    request: request,
                    retryOnNetworkLoss: false
                )
            }
            throw NetworkError.unknown(error)
        }
    }
    
    // MARK: - Request without response (Empty)
    func requestProtoWithoutData<RequestType: SwiftProtobuf.Message>(
        endpoint: String,
        method: HTTPMethod = .post,
        request: RequestType? = nil
    ) async throws {
        // Use EmptyResponse type
        let _: Campus_Forum_EmptyResponse = try await requestProto(
            endpoint: endpoint,
            method: method,
            request: request
        )
    }
}

