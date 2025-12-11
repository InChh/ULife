//
//  ActivityModels.swift
//  ULife
//
//  Created for mock Activity module
//

import Foundation

/// 活动状态：1 已发布/进行中, 2 已结束, 3 已撤销
enum ActivityStatus: Int, Codable {
    case ongoing = 1
    case ended = 2
    case cancelled = 3
}

/// 活动类型：1 讲座, 2 社团, 3 竞赛
enum ActivityType: Int, Codable, CaseIterable {
    case lecture = 1
    case club = 2
    case competition = 3
    
    var displayName: String {
        switch self {
        case .lecture: return "讲座"
        case .club: return "社团"
        case .competition: return "竞赛"
        }
    }
}

/// 完整活动数据模型
struct Activity: Identifiable, Codable {
    let id: String
    var title: String
    var content: String
    var coverURL: String
    var activityType: ActivityType
    var location: String
    var organizer: String
    var startTime: Date
    var endTime: Date
    var quota: Int
    var currentEnrollments: Int
    var needSignIn: Bool
    var status: ActivityStatus
    var createdAt: Date
    
    /// 仅在详情接口返回
    var isEnrolled: Bool = false
    var isCollected: Bool = false
}

/// 列表项（接口返回部分字段）
struct ActivityListItem: Identifiable {
    let id: String
    let title: String
    let coverURL: String
    let location: String
    let startTime: Date
    let quota: Int
    let currentEnrollments: Int
}

/// 活动模块专用分页信息（避免与论坛等模块重名）
struct ActivityPagination {
    let total: Int
    let page: Int
    let pageSize: Int
    var pages: Int {
        guard pageSize > 0 else { return 0 }
        return Int(ceil(Double(total) / Double(pageSize)))
    }
}

/// 报名信息
struct EnrollmentRecord: Identifiable {
    let id: String
    let userId: String
    let userName: String
    let studentId: String
    let major: String
    let phoneNumber: String?
    let activityId: String
    let enrollTime: Date
    /// 1 已报名，2 取消
    var attendanceStatus: Int
    
    init(userId: String,
         userName: String,
         studentId: String,
         major: String,
         phoneNumber: String?,
         activityId: String,
         enrollTime: Date,
         attendanceStatus: Int) {
        self.id = UUID().uuidString
        self.userId = userId
        self.userName = userName
        self.studentId = studentId
        self.major = major
        self.phoneNumber = phoneNumber
        self.activityId = activityId
        self.enrollTime = enrollTime
        self.attendanceStatus = attendanceStatus
    }
}

/// 我的报名活动
struct MyEnrollmentItem: Identifiable {
    let id = UUID().uuidString
    let activityId: String
    let title: String
    let coverURL: String
    let startTime: Date
    let endTime: Date
    /// 1:已报名, 2:已取消报名
    let myStatus: Int
}

/// 我的收藏活动
struct MyCollectionItem: Identifiable {
    let id = UUID().uuidString
    let activityId: String
    let title: String
    let coverURL: String
    let startTime: Date
    let endTime: Date
}

