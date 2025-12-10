//
//  ActivityDataManager.swift
//  ULife
//
//  Mock implementation for Activity APIs (no backend request)
//

import Foundation

final class ActivityDataManager {
    static let shared = ActivityDataManager()
    
    private var activities: [Activity] = []
    private var enrollmentMap: [String: EnrollmentRecord] = [:] // key: activityId
    private var collectionSet: Set<String> = []
    
    private init() {
        seedMockData()
    }
    
    // MARK: - Mock seed
    private func seedMockData() {
        let now = Date()
        let day: TimeInterval = 24 * 60 * 60
        
        let samples: [Activity] = [
            Activity(
                id: "A10001",
                title: "AI 前沿讲座：大模型与校园应用",
                content: "邀请校友分享大模型在学习、科研、生活中的落地案例，并现场 Q&A。",
                coverURL: "",
                activityType: .lecture,
                location: "科技楼报告厅 301",
                organizer: "计算机学院 / 校友会",
                startTime: now.addingTimeInterval(day),
                endTime: now.addingTimeInterval(day + 2 * 60 * 60),
                quota: 80,
                currentEnrollments: 36,
                needSignIn: true,
                status: .ongoing,
                createdAt: now.addingTimeInterval(-day * 2)
            ),
            Activity(
                id: "A20002",
                title: "校园马拉松志愿者招募",
                content: "协助赛道秩序维护、物资发放、急救引导，提供志愿者时长证明。",
                coverURL: "",
                activityType: .club,
                location: "田径场北门集合",
                organizer: "体育部 / 志愿者协会",
                startTime: now.addingTimeInterval(day * 3),
                endTime: now.addingTimeInterval(day * 3 + 3 * 60 * 60),
                quota: 120,
                currentEnrollments: 95,
                needSignIn: false,
                status: .ongoing,
                createdAt: now.addingTimeInterval(-day)
            ),
            Activity(
                id: "A30003",
                title: "编程竞赛训练营选拔赛",
                content: "笔试 + 上机赛，选拔校赛代表队，欢迎 22/23/24 级同学报名。",
                coverURL: "",
                activityType: .competition,
                location: "实验楼机房 502",
                organizer: "信息竞赛中心",
                startTime: now.addingTimeInterval(day * 5),
                endTime: now.addingTimeInterval(day * 5 + 4 * 60 * 60),
                quota: 60,
                currentEnrollments: 58,
                needSignIn: true,
                status: .ongoing,
                createdAt: now.addingTimeInterval(-day * 3)
            )
        ]
        activities = samples
    }
    
    // MARK: - Helpers
    private func filter(keyword: String?, activityType: ActivityType?) -> [Activity] {
        return activities.filter { activity in
            let matchType = activityType == nil || activity.activityType == activityType
            let matchKeyword: Bool
            if let key = keyword?.lowercased(), !key.isEmpty {
                matchKeyword = activity.title.lowercased().contains(key) ||
                               activity.content.lowercased().contains(key) ||
                               activity.location.lowercased().contains(key)
            } else {
                matchKeyword = true
            }
            return matchType && matchKeyword
        }
    }
    
    private func paginate(list: [Activity], page: Int, pageSize: Int) -> (items: [Activity], pagination: ActivityPagination) {
        let safePage = max(page, 1)
        let safePageSize = max(pageSize, 1)
        let start = (safePage - 1) * safePageSize
        let end = min(start + safePageSize, list.count)
        let sliced = start < end ? Array(list[start..<end]) : []
        let pagination = ActivityPagination(total: list.count, page: safePage, pageSize: safePageSize)
        return (sliced, pagination)
    }
    
    // MARK: - Public API (mock)
    
    func fetchActivities(keyword: String? = nil,
                         activityType: ActivityType? = nil,
                         page: Int = 1,
                         pageSize: Int = 10) -> (list: [ActivityListItem], pagination: ActivityPagination) {
        let filtered = filter(keyword: keyword, activityType: activityType)
        let result = paginate(list: filtered, page: page, pageSize: pageSize)
        let items = result.items.map { activity in
            ActivityListItem(
                id: activity.id,
                title: activity.title,
                coverURL: activity.coverURL,
                location: activity.location,
                startTime: activity.startTime,
                quota: activity.quota,
                currentEnrollments: activity.currentEnrollments
            )
        }
        return (items, result.pagination)
    }
    
    func getActivityDetail(activityId: String) -> Activity? {
        guard var activity = activities.first(where: { $0.id == activityId }) else { return nil }
        activity.isEnrolled = enrollmentMap[activityId] != nil
        activity.isCollected = collectionSet.contains(activityId)
        return activity
    }
    
    enum ActivityActionError: Error {
        case notFound
        case quotaFull
        case alreadyEnrolled
        case alreadyCancelled
        case timeConflict
    }
    
    // 学生报名
    func enroll(activityId: String,
                userName: String,
                studentId: String,
                major: String,
                phoneNumber: String?) throws {
        guard let idx = activities.firstIndex(where: { $0.id == activityId }) else {
            throw ActivityActionError.notFound
        }
        guard enrollmentMap[activityId] == nil else {
            throw ActivityActionError.alreadyEnrolled
        }
        guard activities[idx].currentEnrollments < activities[idx].quota else {
            throw ActivityActionError.quotaFull
        }
        
        let record = EnrollmentRecord(
            userId: studentId,
            userName: userName,
            studentId: studentId,
            major: major,
            phoneNumber: phoneNumber,
            activityId: activityId,
            enrollTime: Date(),
            attendanceStatus: 1
        )
        enrollmentMap[activityId] = record
        activities[idx].currentEnrollments += 1
    }
    
    // 取消报名
    func cancelEnroll(activityId: String) throws {
        guard let idx = activities.firstIndex(where: { $0.id == activityId }) else {
            throw ActivityActionError.notFound
        }
        guard let record = enrollmentMap[activityId] else {
            throw ActivityActionError.notFound
        }
        guard record.attendanceStatus == 1 else {
            throw ActivityActionError.alreadyCancelled
        }
        enrollmentMap.removeValue(forKey: activityId)
        activities[idx].currentEnrollments = max(0, activities[idx].currentEnrollments - 1)
    }
    
    // 收藏
    func collect(activityId: String) throws {
        guard activities.contains(where: { $0.id == activityId }) else {
            throw ActivityActionError.notFound
        }
        collectionSet.insert(activityId)
    }
    
    func cancelCollect(activityId: String) throws {
        guard activities.contains(where: { $0.id == activityId }) else {
            throw ActivityActionError.notFound
        }
        collectionSet.remove(activityId)
    }
    
    // 我的活动
    func fetchMyActivities(includeEnrollments: Bool,
                           includeCollections: Bool,
                           page: Int = 1,
                           pageSize: Int = 10) -> (enrolled: ([MyEnrollmentItem], ActivityPagination)?, collected: ([MyCollectionItem], ActivityPagination)?) {
        var enrolledResult: ([MyEnrollmentItem], ActivityPagination)? = nil
        if includeEnrollments {
            let enrolledActivities: [MyEnrollmentItem] = enrollmentMap.values.compactMap { record in
                guard let activity = activities.first(where: { $0.id == record.activityId }) else { return nil }
                return MyEnrollmentItem(
                    activityId: activity.id,
                    title: activity.title,
                    coverURL: activity.coverURL,
                    startTime: activity.startTime,
                    endTime: activity.endTime,
                    myStatus: 1
                )
            }
            let result = paginateMy(list: enrolledActivities, page: page, pageSize: pageSize)
            enrolledResult = result
        }
        
        var collectedResult: ([MyCollectionItem], ActivityPagination)? = nil
        if includeCollections {
            let collectedActivities: [MyCollectionItem] = activities
                .filter { collectionSet.contains($0.id) }
                .map { activity in
                    MyCollectionItem(
                        activityId: activity.id,
                        title: activity.title,
                        coverURL: activity.coverURL,
                        startTime: activity.startTime,
                        endTime: activity.endTime
                    )
                }
            let result = paginateMyCollection(list: collectedActivities, page: page, pageSize: pageSize)
            collectedResult = result
        }
        
        return (enrolledResult, collectedResult)
    }
    
    private func paginateMy<T>(list: [T], page: Int, pageSize: Int) -> ([T], ActivityPagination) {
        let safePage = max(page, 1)
        let safePageSize = max(pageSize, 1)
        let start = (safePage - 1) * safePageSize
        let end = min(start + safePageSize, list.count)
        let sliced = start < end ? Array(list[start..<end]) : []
        let pagination = ActivityPagination(total: list.count, page: safePage, pageSize: safePageSize)
        return (sliced, pagination)
    }
    
    private func paginateMyCollection(list: [MyCollectionItem], page: Int, pageSize: Int) -> ([MyCollectionItem], ActivityPagination) {
        let safePage = max(page, 1)
        let safePageSize = max(pageSize, 1)
        let start = (safePage - 1) * safePageSize
        let end = min(start + safePageSize, list.count)
        let sliced = start < end ? Array(list[start..<end]) : []
        let pagination = ActivityPagination(total: list.count, page: safePage, pageSize: safePageSize)
        return (sliced, pagination)
    }
}

