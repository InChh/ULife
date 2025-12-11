//
//  ActivityDataManager.swift
//  ULife
//
//  Real implementation for Activity APIs with backend integration
//

import Foundation

// MARK: - Response Models (Activity Module)
struct ActivityListResponse: Codable {
    let list: [ActivityListItemDTO]
    let pagination: ActivityPaginationDTO
}

struct ActivityListItemDTO: Codable {
    let id: String
    let title: String
    let coverURL: String?
    let location: String
    let startTime: String
    let quota: Int
    let currentEnrollments: Int
    
    enum CodingKeys: String, CodingKey {
        case id, title, location, quota
        case coverURL = "cover_url"
        case startTime = "start_time"
        case currentEnrollments = "current_enrollments"
    }
}

struct ActivityDetailDTO: Codable {
    let id: String
    let title: String
    let content: String
    let coverURL: String?
    let activityType: Int
    let location: String
    let organizer: String
    let startTime: String
    let endTime: String
    let quota: Int
    let currentEnrollments: Int
    let needSignIn: Bool
    let status: Int
    let createdAt: String
    let isEnrolled: Bool
    let isCollected: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, title, content, location, organizer, quota, status
        case coverURL = "cover_url"
        case activityType = "activity_type"
        case startTime = "start_time"
        case endTime = "end_time"
        case currentEnrollments = "current_enrollments"
        case needSignIn = "need_sign_in"
        case createdAt = "created_at"
        case isEnrolled = "is_enrolled"
        case isCollected = "is_collected"
    }
}

struct ActivityPaginationDTO: Codable {
    let total: Int
    let page: Int
    let pageSize: Int
    let pages: Int
    
    enum CodingKeys: String, CodingKey {
        case total, page, pages
        case pageSize = "page_size"
    }
}

struct EnrollActivityRequestDTO: Codable {
    let userName: String
    let studentId: String
    let major: String
    let phoneNumber: String?
    
    enum CodingKeys: String, CodingKey {
        case userName = "user_name"
        case studentId = "student_id"
        case major
        case phoneNumber = "phone_number"
    }
}

struct MyActivitiesResponse: Codable {
    let enrolledData: EnrolledDataDTO?
    let collectedData: CollectedDataDTO?
    
    enum CodingKeys: String, CodingKey {
        case enrolledData = "enrolled_data"
        case collectedData = "collected_data"
    }
}

struct EnrolledDataDTO: Codable {
    let list: [MyEnrollmentItemDTO]
    let pagination: ActivityPaginationDTO
}

struct MyEnrollmentItemDTO: Codable {
    let activityId: String
    let title: String
    let coverURL: String?
    let startTime: String
    let endTime: String
    let myStatus: Int
    
    enum CodingKeys: String, CodingKey {
        case title
        case activityId = "activity_id"
        case coverURL = "cover_url"
        case startTime = "start_time"
        case endTime = "end_time"
        case myStatus = "my_status"
    }
}

struct CollectedDataDTO: Codable {
    let list: [MyCollectionItemDTO]
    let pagination: ActivityPaginationDTO
}

struct MyCollectionItemDTO: Codable {
    let activityId: String
    let title: String
    let coverURL: String?
    let startTime: String
    let endTime: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case activityId = "activity_id"
        case coverURL = "cover_url"
        case startTime = "start_time"
        case endTime = "end_time"
    }
}

// MARK: - Activity Data Manager
final class ActivityDataManager {
    static let shared = ActivityDataManager()
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    // MARK: - Date Formatter
    private lazy var iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    // 备用的日期格式化器（不含毫秒）
    private lazy var iso8601FormatterNoFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    // 辅助方法：解析日期字符串
    private func parseDate(_ dateString: String) -> Date? {
        // 尝试带毫秒的格式
        if let date = iso8601Formatter.date(from: dateString) {
            return date
        }
        // 尝试不带毫秒的格式
        if let date = iso8601FormatterNoFractional.date(from: dateString) {
            return date
        }
        // 如果都失败，打印错误
        print("⚠️ Failed to parse date: \(dateString)")
        return nil
    }
    
    // MARK: - Fetch Activities List
    func fetchActivitiesList(
        keyword: String? = nil,
        activityType: ActivityType? = nil,
        page: Int = 1,
        pageSize: Int = 10
    ) async throws -> (items: [ActivityListItem], pagination: ActivityPagination) {
        var parameters: [String: Any] = [
            "page": page,
            "pageSize": pageSize
        ]
        
        if let keyword = keyword, !keyword.isEmpty {
            parameters["keyword"] = keyword
        }
        
        if let activityType = activityType {
            parameters["activity_type"] = activityType.rawValue
        }
        
        let response: ActivityListResponse = try await networkManager.request(
            endpoint: APIEndpoints.activities,
            method: .get,
            parameters: parameters
        )
        
        print("📥 Received \(response.list.count) activities from server")
        print("📄 Pagination: page \(response.pagination.page) of \(response.pagination.pages)")
        
        // Convert DTO to domain models
        print("🔄 Converting \(response.list.count) DTOs to domain models...")
        let items = response.list.compactMap { dto -> ActivityListItem? in
            print("   Processing: \(dto.title) - start_time: \(dto.startTime)")
            
            guard let startTime = parseDate(dto.startTime) else {
                print("   ❌ Failed to parse date for: \(dto.title)")
                return nil
            }
            
            print("   ✅ Parsed successfully: \(dto.title)")
            
            return ActivityListItem(
                id: dto.id,
                title: dto.title,
                coverURL: dto.coverURL ?? "",
                location: dto.location,
                startTime: startTime,
                quota: dto.quota,
                currentEnrollments: dto.currentEnrollments
            )
        }
        
        let pagination = ActivityPagination(
            total: response.pagination.total,
            page: response.pagination.page,
            pageSize: response.pagination.pageSize
        )
        
        return (items, pagination)
    }
    
    // MARK: - Fetch Activity Detail
    func fetchActivityDetail(activityId: String) async throws -> Activity {
        let dto: ActivityDetailDTO = try await networkManager.request(
            endpoint: APIEndpoints.activityDetail(activityId),
            method: .get
        )
        
        guard let startTime = parseDate(dto.startTime),
              let endTime = parseDate(dto.endTime),
              let createdAt = parseDate(dto.createdAt),
              let activityType = ActivityType(rawValue: dto.activityType),
              let status = ActivityStatus(rawValue: dto.status) else {
            throw NetworkError.decodingError(NSError(domain: "DateParsing", code: -1))
        }
        
        var activity = Activity(
            id: dto.id,
            title: dto.title,
            content: dto.content,
            coverURL: dto.coverURL ?? "",
            activityType: activityType,
            location: dto.location,
            organizer: dto.organizer,
            startTime: startTime,
            endTime: endTime,
            quota: dto.quota,
            currentEnrollments: dto.currentEnrollments,
            needSignIn: dto.needSignIn,
            status: status,
            createdAt: createdAt
        )
        
        activity.isEnrolled = dto.isEnrolled
        activity.isCollected = dto.isCollected
        
        return activity
    }
    
    // MARK: - Enroll Activity
    func enrollActivity(
        activityId: String,
        userName: String,
        studentId: String,
        major: String,
        phoneNumber: String?
    ) async throws {
        let request = EnrollActivityRequestDTO(
            userName: userName,
            studentId: studentId,
            major: major,
            phoneNumber: phoneNumber
        )
        
        try await networkManager.requestWithoutData(
            endpoint: APIEndpoints.enrollActivity(activityId),
            method: .post,
            body: request
        )
    }
    
    // MARK: - Cancel Enrollment
    func cancelEnrollment(activityId: String) async throws {
        try await networkManager.requestWithoutData(
            endpoint: APIEndpoints.enrollActivity(activityId),
            method: .delete
        )
    }
    
    // MARK: - Collect Activity
    func collectActivity(activityId: String) async throws {
        try await networkManager.requestWithoutData(
            endpoint: APIEndpoints.collectActivity(activityId),
            method: .post
        )
    }
    
    // MARK: - Uncollect Activity
    func uncollectActivity(activityId: String) async throws {
        try await networkManager.requestWithoutData(
            endpoint: APIEndpoints.collectActivity(activityId),
            method: .delete
        )
    }
    
    // MARK: - Fetch My Activities
    func fetchMyActivities(
        includeEnrollments: Bool = true,
        includeCollections: Bool = true,
        page: Int = 1,
        pageSize: Int = 10
    ) async throws -> (enrollments: ([MyEnrollmentItem], ActivityPagination)?, collections: ([MyCollectionItem], ActivityPagination)?) {
        var parameters: [String: Any] = [
            "page": page,
            "pageSize": pageSize
        ]
        
        if includeEnrollments {
            parameters["include_enrollments"] = true
        }
        
        if includeCollections {
            parameters["include_collections"] = true
        }
        
        let response: MyActivitiesResponse = try await networkManager.request(
            endpoint: APIEndpoints.myActivities,
            method: .get,
            parameters: parameters
        )
        
        var enrollmentsResult: ([MyEnrollmentItem], ActivityPagination)? = nil
        var collectionsResult: ([MyCollectionItem], ActivityPagination)? = nil
        
        // Parse enrollments
        if let enrolledData = response.enrolledData {
            let items = enrolledData.list.compactMap { dto -> MyEnrollmentItem? in
                guard let startTime = parseDate(dto.startTime),
                      let endTime = parseDate(dto.endTime) else {
                    return nil
                }
                
                return MyEnrollmentItem(
                    activityId: dto.activityId,
                    title: dto.title,
                    coverURL: dto.coverURL ?? "",
                    startTime: startTime,
                    endTime: endTime,
                    myStatus: dto.myStatus
                )
            }
            
            let pagination = ActivityPagination(
                total: enrolledData.pagination.total,
                page: enrolledData.pagination.page,
                pageSize: enrolledData.pagination.pageSize
            )
            
            enrollmentsResult = (items, pagination)
        }
        
        // Parse collections
        if let collectedData = response.collectedData {
            let items = collectedData.list.compactMap { dto -> MyCollectionItem? in
                guard let startTime = parseDate(dto.startTime),
                      let endTime = parseDate(dto.endTime) else {
                    return nil
                }
                
                return MyCollectionItem(
                    activityId: dto.activityId,
                    title: dto.title,
                    coverURL: dto.coverURL ?? "",
                    startTime: startTime,
                    endTime: endTime
                )
            }
            
            let pagination = ActivityPagination(
                total: collectedData.pagination.total,
                page: collectedData.pagination.page,
                pageSize: collectedData.pagination.pageSize
            )
            
            collectionsResult = (items, pagination)
        }
        
        return (enrollmentsResult, collectionsResult)
    }
}
