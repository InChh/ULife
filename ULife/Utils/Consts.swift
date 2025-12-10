//
//  Consts.swift
//  ULife
//
//  Created by 刘宏伟 on 2025/12/1.
//

import Foundation

enum Constants {
    /// API基础URL
    static let baseURL = "http://localhost:3000/api/v1"
    
    /// 请求超时时间
    static let requestTimeout: TimeInterval = 30
    
    /// 分页默认大小
    static let defaultPageSize = 20
}

/// API路径
enum APIPath {
    // 活动相关
    static let activities = "/activities"
    static func activityDetail(_ id: String) -> String {
        return "/activities/\(id)"
    }
    static func enrollActivity(_ id: String) -> String {
        return "/activities/\(id)/enroll"
    }
    static func collectActivity(_ id: String) -> String {
        return "/activities/\(id)/collect"
    }
    static func activityEnrollments(_ id: String) -> String {
        return "/activities/\(id)/enrollments"
    }
    static let myActivities = "/my/activities"
}
