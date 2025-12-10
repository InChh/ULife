//
//  ActivityService.swift
//  ULife
//
//  Created on 2025/12/1.
//

import Foundation

/// 活动服务层
@MainActor
final class ActivityService {
    static let shared = ActivityService()
    
    private let networkManager = NetworkManager.shared
    
    /// 是否使用 Mock 数据（开发调试时设为 true）
    var useMockData: Bool = true
    
    private init() {}
    
    // MARK: - 获取活动列表
    
    /// 获取活动列表
    func fetchActivities(
        keyword: String? = nil,
        activityType: ActivityType? = nil,
        page: Int = 1,
        pageSize: Int = Constants.defaultPageSize
    ) async throws -> (activities: [ActivityListItem], pagination: Pagination) {
        // 使用 Mock 数据
        if useMockData {
            return fetchActivitiesMock(keyword: keyword, activityType: activityType, page: page, pageSize: pageSize)
        }
        
        // 使用真实接口
        let response = try await networkManager.getActivities(
            keyword: keyword,
            activityType: activityType?.rawValue,
            page: page,
            pageSize: pageSize
        )
        
        guard response.code == 0, let data = response.data else {
            throw ActivityError.apiError(message: response.message)
        }
        
        return (data.list, data.pagination)
    }
    
    /// Mock 方式获取活动列表
    private func fetchActivitiesMock(
        keyword: String?,
        activityType: ActivityType?,
        page: Int,
        pageSize: Int
    ) -> (activities: [ActivityListItem], pagination: Pagination) {
        var activities = MockActivityData.activities
        
        // 关键词筛选
        if let keyword = keyword, !keyword.isEmpty {
            activities = activities.filter {
                $0.title.localizedCaseInsensitiveContains(keyword) ||
                $0.location.localizedCaseInsensitiveContains(keyword)
            }
        }
        
        // 类型筛选：通过详情数据获取类型
        if let activityType = activityType {
            activities = activities.filter { item in
                // 从详情中获取类型进行筛选
                if let detail = MockActivityData.getActivityDetail(id: item.id) {
                    return detail.activityType == activityType
                }
                return false
            }
        }
        
        // 分页处理
        let total = activities.count
        let startIndex = (page - 1) * pageSize
        let endIndex = min(startIndex + pageSize, total)
        
        let paginatedActivities = startIndex < total ? Array(activities[startIndex..<endIndex]) : []
        let pagination = MockActivityData.getPagination(page: page, pageSize: pageSize, total: total)
        
        return (paginatedActivities, pagination)
    }
    
    // MARK: - 获取活动详情
    
    /// 获取活动详情
    func fetchActivityDetail(id: String) async throws -> Activity {
        // 使用 Mock 数据
        if useMockData {
            if let activity = MockActivityData.getActivityDetail(id: id) {
                return activity
            } else {
                throw ActivityError.notFound
            }
        }
        
        // 使用真实接口
        let response = try await networkManager.getActivityDetail(id: id)
        
        guard response.code == 0, let activity = response.data else {
            throw ActivityError.apiError(message: response.message)
        }
        
        return activity
    }
    
    // MARK: - 报名相关
    
    /// 报名活动
    func enrollActivity(
        activityId: String,
        userName: String,
        studentId: String,
        major: String,
        phoneNumber: String?
    ) async throws {
        // 使用 Mock 数据
        if useMockData {
            // Mock 模式下直接成功，更新本地状态
            if var activity = MockActivityData.getActivityDetail(id: activityId) {
                activity.isEnrolled = true
            }
            return
        }
        
        // 使用真实接口
        let request = EnrollActivityRequest(
            userName: userName,
            studentId: studentId,
            major: major,
            phoneNumber: phoneNumber
        )
        
        let response = try await networkManager.enrollActivity(id: activityId, request: request)
        
        guard response.code == 0 else {
            throw ActivityError.apiError(message: response.message)
        }
    }
    
    /// 取消报名
    func cancelEnrollment(activityId: String) async throws {
        // 使用 Mock 数据
        if useMockData {
            // Mock 模式下直接成功
            return
        }
        
        // 使用真实接口
        let response = try await networkManager.cancelEnrollment(activityId: activityId)
        
        guard response.code == 0 else {
            throw ActivityError.apiError(message: response.message)
        }
    }
    
    // MARK: - 收藏相关
    
    /// 收藏活动
    func collectActivity(activityId: String) async throws {
        // 使用 Mock 数据
        if useMockData {
            // Mock 模式下直接成功
            return
        }
        
        // 使用真实接口
        let response = try await networkManager.collectActivity(id: activityId)
        
        guard response.code == 0 else {
            throw ActivityError.apiError(message: response.message)
        }
    }
    
    /// 取消收藏
    func uncollectActivity(activityId: String) async throws {
        // 使用 Mock 数据
        if useMockData {
            // Mock 模式下直接成功
            return
        }
        
        // 使用真实接口
        let response = try await networkManager.uncollectActivity(id: activityId)
        
        guard response.code == 0 else {
            throw ActivityError.apiError(message: response.message)
        }
    }
    
    // MARK: - 我的活动
    
    /// 获取我的活动（报名+收藏）
    func fetchMyActivities(
        includeEnrollments: Bool = true,
        includeCollections: Bool = true,
        page: Int = 1,
        pageSize: Int = Constants.defaultPageSize
    ) async throws -> MyActivitiesResponse {
        // 使用 Mock 数据
        if useMockData {
            return fetchMyActivitiesMock(
                includeEnrollments: includeEnrollments,
                includeCollections: includeCollections,
                page: page,
                pageSize: pageSize
            )
        }
        
        // 使用真实接口
        let response = try await networkManager.getMyActivities(
            includeEnrollments: includeEnrollments,
            includeCollections: includeCollections,
            page: page,
            pageSize: pageSize
        )
        
        guard response.code == 0, let data = response.data else {
            throw ActivityError.apiError(message: response.message)
        }
        
        return data
    }
    
    /// Mock 方式获取我的活动
    private func fetchMyActivitiesMock(
        includeEnrollments: Bool,
        includeCollections: Bool,
        page: Int,
        pageSize: Int
    ) -> MyActivitiesResponse {
        var enrolledData: EnrolledData?
        var collectedData: CollectedData?
        
        if includeEnrollments {
            let enrollments = MockActivityData.myEnrollments
            let pagination = MockActivityData.getPagination(
                page: page,
                pageSize: pageSize,
                total: enrollments.count
            )
            enrolledData = EnrolledData(pagination: pagination, list: enrollments)
        }
        
        if includeCollections {
            let collections = MockActivityData.myCollections
            let pagination = MockActivityData.getPagination(
                page: page,
                pageSize: pageSize,
                total: collections.count
            )
            collectedData = CollectedData(pagination: pagination, list: collections)
        }
        
        return MyActivitiesResponse(
            enrolledData: enrolledData,
            collectedData: collectedData
        )
    }
}

/// 活动错误类型
enum ActivityError: LocalizedError {
    case apiError(message: String)
    case networkError(Error)
    case notFound
    case alreadyEnrolled
    case enrollmentFull
    case enrollmentClosed
    
    var errorDescription: String? {
        switch self {
        case .apiError(let message):
            return message
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .notFound:
            return "活动不存在"
        case .alreadyEnrolled:
            return "您已报名该活动"
        case .enrollmentFull:
            return "活动报名人数已满"
        case .enrollmentClosed:
            return "活动报名已截止"
        }
    }
}

