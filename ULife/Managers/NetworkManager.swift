//
//  NetworkManager.swift
//  ULife
//
//  Created by 刘宏伟 on 2025/12/1.
//

import Foundation

/// 网络请求管理器
final class NetworkManager {
    static let shared = NetworkManager()
    
    private let session: URLSession
    private let baseURL: String
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Constants.requestTimeout
        configuration.timeoutIntervalForResource = Constants.requestTimeout
        self.session = URLSession(configuration: configuration)
        self.baseURL = Constants.baseURL
    }
    
    /// 获取认证Token（从UserDefaults或其他存储中）
    private func getAuthToken() -> String? {
        return UserDefaults.standard.string(forKey: "auth_token")
    }
    
    /// 通用请求方法
    private func performRequest<T: Decodable>(
        path: String,
        method: String = "GET",
        body: Encodable? = nil,
        queryParams: [String: Any]? = nil
    ) async throws -> T {
        var urlString = baseURL + path
        
        // 添加查询参数
        if let queryParams = queryParams, !queryParams.isEmpty {
            let components = URLComponents(string: urlString)
            var newComponents = components
            newComponents?.queryItems = queryParams.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
            urlString = newComponents?.url?.absoluteString ?? urlString
        }
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 添加认证Token
        if let token = getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // 添加请求体
        if let body = body {
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                request.httpBody = try encoder.encode(body)
            } catch {
                throw NetworkError.encodingError(error)
            }
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            // 检查HTTP状态码
            guard (200...299).contains(httpResponse.statusCode) else {
                // 尝试解析错误响应
                if let errorResponse = try? JSONDecoder().decode(APIResponse<String?>.self, from: data) {
                    throw NetworkError.apiError(code: errorResponse.code, message: errorResponse.message)
                }
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
            }
            
            // 解析响应
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let result = try decoder.decode(T.self, from: data)
            return result
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    // MARK: - 活动相关API
    
    /// 获取活动列表
    func getActivities(
        keyword: String? = nil,
        activityType: Int? = nil,
        page: Int = 1,
        pageSize: Int = Constants.defaultPageSize
    ) async throws -> APIResponse<ActivityListResponse> {
        var queryParams: [String: Any] = [
            "page": page,
            "pageSize": pageSize
        ]
        
        if let keyword = keyword, !keyword.isEmpty {
            queryParams["keyword"] = keyword
        }
        
        if let activityType = activityType {
            queryParams["activity_type"] = activityType
        }
        
        return try await performRequest(
            path: APIPath.activities,
            method: "GET",
            queryParams: queryParams
        )
    }
    
    /// 获取活动详情
    func getActivityDetail(id: String) async throws -> APIResponse<Activity> {
        return try await performRequest(path: APIPath.activityDetail(id), method: "GET")
    }
    
    /// 创建活动（管理员）
    func createActivity(_ request: CreateActivityRequest) async throws -> APIResponse<[Activity]> {
        return try await performRequest(
            path: APIPath.activities,
            method: "POST",
            body: request
        )
    }
    
    /// 更新活动（管理员）
    func updateActivity(id: String, request: UpdateActivityRequest) async throws -> SimpleSuccessResponse {
        return try await performRequest(
            path: APIPath.activityDetail(id),
            method: "PATCH",
            body: request
        )
    }
    
    /// 报名活动
    func enrollActivity(id: String, request: EnrollActivityRequest) async throws -> SimpleSuccessResponse {
        return try await performRequest(
            path: APIPath.enrollActivity(id),
            method: "POST",
            body: request
        )
    }
    
    /// 取消报名
    func cancelEnrollment(activityId: String) async throws -> SimpleSuccessResponse {
        return try await performRequest(
            path: APIPath.enrollActivity(activityId),
            method: "DELETE"
        )
    }
    
    /// 收藏活动
    func collectActivity(id: String) async throws -> SimpleSuccessResponse {
        return try await performRequest(
            path: APIPath.collectActivity(id),
            method: "POST"
        )
    }
    
    /// 取消收藏
    func uncollectActivity(id: String) async throws -> SimpleSuccessResponse {
        return try await performRequest(
            path: APIPath.collectActivity(id),
            method: "DELETE"
        )
    }
    
    /// 获取活动报名列表（管理员）
    func getActivityEnrollments(activityId: String) async throws -> APIResponse<EnrollmentListResponse> {
        return try await performRequest(
            path: APIPath.activityEnrollments(activityId),
            method: "GET"
        )
    }
    
    /// 获取我的活动（报名+收藏）
    func getMyActivities(
        includeEnrollments: Bool = true,
        includeCollections: Bool = true,
        page: Int = 1,
        pageSize: Int = Constants.defaultPageSize
    ) async throws -> APIResponse<MyActivitiesResponse> {
        var queryParams: [String: Any] = [
            "include_enrollments": includeEnrollments,
            "include_collections": includeCollections,
            "page": page,
            "pageSize": pageSize
        ]
        
        return try await performRequest(
            path: APIPath.myActivities,
            method: "GET",
            queryParams: queryParams
        )
    }
}

/// 网络错误类型
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case apiError(code: Int, message: String)
    case encodingError(Error)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .invalidResponse:
            return "无效的响应"
        case .httpError(let statusCode):
            return "HTTP错误: \(statusCode)"
        case .apiError(let code, let message):
            return "API错误 [\(code)]: \(message)"
        case .encodingError(let error):
            return "编码错误: \(error.localizedDescription)"
        case .decodingError(let error):
            return "解码错误: \(error.localizedDescription)"
        }
    }
}

/// 报名列表响应
struct EnrollmentListResponse: Codable {
    let totalEnrolled: Int
    let enrollmentList: [EnrollmentRecord]
    
    enum CodingKeys: String, CodingKey {
        case totalEnrolled = "total_enrolled"
        case enrollmentList = "enrollment_list"
    }
}
