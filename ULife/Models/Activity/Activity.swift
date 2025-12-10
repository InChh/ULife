//
//  Activity.swift
//  ULife
//
//  Created on 2025/12/1.
//

import Foundation

/// 活动实体
struct Activity: Codable {
    let id: String
    let title: String
    let content: String
    let coverUrl: String
    let activityType: ActivityType
    let location: String
    let organizer: String
    let startTime: Date
    let endTime: Date
    let quota: Int
    let currentEnrollments: Int
    let needSignIn: Bool
    let status: ActivityStatus
    let createdAt: Date
    
    // 活动详情额外字段
    var isEnrolled: Bool?
    var isCollected: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case coverUrl = "cover_url"
        case activityType = "activity_type"
        case location
        case organizer
        case startTime = "start_time"
        case endTime = "end_time"
        case quota
        case currentEnrollments = "current_enrollments"
        case needSignIn = "need_sign_in"
        case status
        case createdAt = "created_at"
        case isEnrolled = "is_enrolled"
        case isCollected = "is_collected"
    }
}

/// 活动类型
enum ActivityType: Int, Codable {
    case lecture = 1    // 讲座
    case club = 2      // 社团
    case competition = 3 // 竞赛
    
    var displayName: String {
        switch self {
        case .lecture: return "讲座"
        case .club: return "社团"
        case .competition: return "竞赛"
        }
    }
}

/// 活动状态
enum ActivityStatus: Int, Codable {
    case published = 1  // 已发布/进行中
    case ended = 2       // 已结束
    case cancelled = 3   // 已撤销
    
    var displayName: String {
        switch self {
        case .published: return "进行中"
        case .ended: return "已结束"
        case .cancelled: return "已撤销"
        }
    }
}

/// 活动列表项（简化版，用于列表展示）
struct ActivityListItem: Codable {
    let id: String
    let title: String
    let coverUrl: String
    let location: String
    let startTime: Date
    let quota: Int
    let currentEnrollments: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case coverUrl = "cover_url"
        case location
        case startTime = "start_time"
        case quota
        case currentEnrollments = "current_enrollments"
    }
}

/// 分页信息
struct Pagination: Codable {
    let total: Int
    let page: Int
    let pageSize: Int
    let pages: Int
    
    enum CodingKeys: String, CodingKey {
        case total
        case page
        case pageSize
        case pages
    }
}

/// 活动列表响应
struct ActivityListResponse: Codable {
    let list: [ActivityListItem]
    let pagination: Pagination
}

/// 创建活动请求
struct CreateActivityRequest: Codable {
    let title: String
    let content: String
    let location: String
    let organizer: String
    let startTime: Date
    let endTime: Date
    
    enum CodingKeys: String, CodingKey {
        case title
        case content
        case location
        case organizer
        case startTime = "start_time"
        case endTime = "end_time"
    }
}

/// 修改活动请求
struct UpdateActivityRequest: Codable {
    let title: String?
    let content: String?
    let coverUrl: String?
    let activityType: ActivityType?
    let location: String?
    let organizer: String?
    let startTime: Date?
    let endTime: Date?
    let quota: Int?
    let needSignIn: Bool?
    let status: ActivityStatus?
    
    enum CodingKeys: String, CodingKey {
        case title
        case content
        case coverUrl = "cover_url"
        case activityType = "activity_type"
        case location
        case organizer
        case startTime = "start_time"
        case endTime = "end_time"
        case quota
        case needSignIn = "need_sign_in"
        case status
    }
}

/// 报名活动请求
struct EnrollActivityRequest: Codable {
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

/// 报名记录
struct EnrollmentRecord: Codable {
    let userId: String
    let userName: String
    let studentId: String
    let major: String
    let phoneNumber: String?
    let activityId: String
    let enrollTime: Date
    let attendanceStatus: AttendanceStatus
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case userName = "user_name"
        case studentId = "student_id"
        case major
        case phoneNumber = "phone_number"
        case activityId = "activity_id"
        case enrollTime = "enroll_time"
        case attendanceStatus = "attendance_status"
    }
}

/// 签到状态
enum AttendanceStatus: Int, Codable {
    case notSigned = 1  // 未签到
    case signed = 2      // 已签到
}

/// 报名信息响应
struct EnrollmentResponse: Codable {
    let activityId: String
    let title: String
    let coverUrl: String
    let startTime: Date
    let endTime: Date
    let myStatus: EnrollmentStatus
    
    enum CodingKeys: String, CodingKey {
        case activityId = "activity_id"
        case title
        case coverUrl = "cover_url"
        case startTime = "start_time"
        case endTime = "end_time"
        case myStatus = "my_status"
    }
}

/// 报名状态
enum EnrollmentStatus: Int, Codable {
    case enrolled = 1      // 已报名
    case cancelled = 2     // 已取消报名
}

/// 收藏信息响应
struct CollectionResponse: Codable {
    let activityId: String
    let title: String
    let coverUrl: String
    let startTime: Date
    let endTime: Date
    
    enum CodingKeys: String, CodingKey {
        case activityId = "activity_id"
        case title
        case coverUrl = "cover_url"
        case startTime = "start_time"
        case endTime = "end_time"
    }
}

/// 我的活动响应
struct MyActivitiesResponse: Codable {
    let enrolledData: EnrolledData?
    let collectedData: CollectedData?
    
    enum CodingKeys: String, CodingKey {
        case enrolledData = "enrolled_data"
        case collectedData = "collected_data"
    }
}

struct EnrolledData: Codable {
    let pagination: Pagination
    let list: [EnrollmentResponse]
}

struct CollectedData: Codable {
    let pagination: Pagination
    let list: [CollectionResponse]
}

/// 统一API响应格式
struct APIResponse<T: Codable>: Codable {
    let code: Int
    let message: String
    let data: T?
}

/// 简单成功响应（data为null）
struct SimpleSuccessResponse: Codable {
    let code: Int
    let message: String
    let data: String?
}

