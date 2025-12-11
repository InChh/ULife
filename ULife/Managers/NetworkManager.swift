//
//  NetworkManager.swift
//  ULife
//
//  Created by 刘宏伟 on 2025/12/1.
//

import Foundation

// MARK: - Network Error
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int, String)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

// MARK: - HTTP Method
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - API Response
struct APIResponse<T: Decodable>: Decodable {
    let code: Int
    let message: String
    let data: T?
}

// MARK: - Network Manager
class NetworkManager {
    static let shared = NetworkManager()
    
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
    
    // MARK: - Generic Request
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        body: Encodable? = nil
    ) async throws -> T {
        // Build URL
        var urlString = APIConfig.baseURL + endpoint
        
        // Add query parameters for GET requests
        if method == .get, let params = parameters {
            var components = URLComponents(string: urlString)
            components?.queryItems = params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            urlString = components?.url?.absoluteString ?? urlString
        }
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth token if available
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add request body
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw NetworkError.unknown(error)
            }
        }
        
        // Perform request
        do {
            let (data, response) = try await session.data(for: request)
            
            // Check HTTP status
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.noData
            }
            
            // Log response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📥 Response [\(httpResponse.statusCode)]: \(jsonString)")
            }
            
            // Handle non-200 status codes with graceful fallback parsing
            guard (200...299).contains(httpResponse.statusCode) else {
                if let apiError = try? JSONDecoder().decode(APIResponse<String?>.self, from: data) {
                    throw NetworkError.serverError(apiError.code, apiError.message)
                }
                if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let code = (dict["status"] as? Int) ?? httpResponse.statusCode
                    let message = (dict["error"] as? String)
                        ?? (dict["message"] as? String)
                        ?? "Unknown error"
                    throw NetworkError.serverError(code, message)
                }
                throw NetworkError.serverError(httpResponse.statusCode, "Unknown error")
            }
            
            // Decode response
            do {
                let decoder = JSONDecoder()
                // 不设置 dateDecodingStrategy，让 DTO 使用 String 接收日期
                // decoder.dateDecodingStrategy = .iso8601
                
                // 先打印原始 JSON（用于调试）
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📄 Raw JSON (first 500 chars): \(jsonString.prefix(500))")
                }
                
                let apiResponse = try decoder.decode(APIResponse<T>.self, from: data)
                
                print("✅ API Response decoded")
                print("   Code: \(apiResponse.code)")
                print("   Message: \(apiResponse.message)")
                print("   Has data: \(apiResponse.data != nil)")
                
                if apiResponse.code == 200, let data = apiResponse.data {
                    return data
                }
                throw NetworkError.serverError(apiResponse.code, apiResponse.message)
            } catch {
                print("❌ Decoding error: \(error)")
                
                // 详细的解码错误信息
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("   ❌ Missing key: \(key.stringValue)")
                        print("   ❌ Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                        print("   ❌ Debug: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("   ❌ Type mismatch: expected \(type)")
                        print("   ❌ Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                        print("   ❌ Debug: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("   ❌ Value not found for type: \(type)")
                        print("   ❌ Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                        print("   ❌ Debug: \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("   ❌ Data corrupted")
                        print("   ❌ Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                        print("   ❌ Debug: \(context.debugDescription)")
                    @unknown default:
                        print("   ❌ Unknown decoding error")
                    }
                }
                
                // 如果 2xx 但解码失败，尝试解析错误消息
                if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let code = (dict["code"] as? Int) ?? 200
                    let message = (dict["message"] as? String) ?? "Decode failed"
                    throw NetworkError.serverError(code, message)
                }
                throw NetworkError.decodingError(error)
            }
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }
    
    // MARK: - Request without response data
    func requestWithoutData(
        endpoint: String,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        body: Encodable? = nil
    ) async throws {
        // 构造 URL
        var urlString = APIConfig.baseURL + endpoint
        if method == .get, let params = parameters {
            var components = URLComponents(string: urlString)
            components?.queryItems = params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            urlString = components?.url?.absoluteString ?? urlString
        }
        guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }
        
        // 构造请求
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        // 非 2xx 解析错误信息
        guard (200...299).contains(httpResponse.statusCode) else {
            if let apiError = try? JSONDecoder().decode(APIResponse<String?>.self, from: data) {
                throw NetworkError.serverError(apiError.code, apiError.message)
            }
            if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let code = (dict["status"] as? Int) ?? httpResponse.statusCode
                let message = (dict["error"] as? String)
                    ?? (dict["message"] as? String)
                    ?? "Unknown error"
                throw NetworkError.serverError(code, message)
            }
            throw NetworkError.serverError(httpResponse.statusCode, "Unknown error")
        }
    }
}
