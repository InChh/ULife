//
//  Consts.swift
//  ULife
//
//  Created by 刘宏伟 on 2025/12/1.
//

import Foundation

// MARK: - API Configuration
struct APIConfig {
    static let baseURL = "http://localhost:3000/api"
    static let timeout: TimeInterval = 30.0
}

// MARK: - API Endpoints
struct APIEndpoints {
    // MARK: - Protobuf Endpoints
    struct protobuf {
        // Forum
        static let forumBoards = "/v1/proto/forum/boards"
        static let forumPosts = "/v1/proto/forum/posts"
        
        // User
        static let login = "/v1/proto/auth/login"
        static let register = "/v1/proto/auth/register"
        
        // Course
        static let semesters = "/v1/proto/semesters"
        static let publicCourses = "/v1/proto/courses/public"
        static let schedule = "/v1/proto/schedule"
    }
    
    // MARK: - User/Auth Endpoints
    static let login = "/v1/auth/login"
    static let register = "/v1/auth/register"
    static let logout = "/v1/auth/logout"
    static let changePassword = "/v1/auth/change-password"
    static let userMe = "/v1/users/me"
    static func deleteUser(_ id: String) -> String {
        return "/v1/users/\(id)"
    }
    
    // MARK: - Forum Endpoints
    static let forumBoards = "/v1/forum/boards"
    static let forumPosts = "/v1/forum/posts"
    static func forumPostDetail(_ id: String) -> String {
        return "/v1/forum/posts/\(id)"
    }
    static func forumPostLike(_ id: String) -> String {
        return "/v1/forum/posts/\(id)/like"
    }
    static func forumPostCollect(_ id: String) -> String {
        return "/v1/forum/posts/\(id)/collect"
    }
    static func forumPostComments(_ id: String) -> String {
        return "/v1/forum/posts/\(id)/comments"
    }
    static func forumCommentDetail(_ id: String) -> String {
        return "/v1/forum/comments/\(id)"
    }
    static func forumCommentLike(_ id: String) -> String {
        return "/v1/forum/comments/\(id)/like"
    }
    static let forumReports = "/v1/forum/reports"
    
    // MARK: - Course/Calendar Endpoints
    static let semesters = "/v1/semesters"
    static let publicCourses = "/v1/courses/public"
    static let schedule = "/v1/schedule"
    
    // MARK: - Activity Endpoints
    static let activities = "/v1/activities"
    static func activityDetail(_ id: String) -> String {
        return "/v1/activities/\(id)"
    }
    static func enrollActivity(_ id: String) -> String {
        return "/v1/activities/\(id)/enroll"
    }
    static func collectActivity(_ id: String) -> String {
        return "/v1/activities/\(id)/collect"
    }
    static func activityEnrollments(_ id: String) -> String {
        return "/v1/activities/\(id)/enrollments"
    }
    static let myActivities = "/v1/my/activities"
    
    // MARK: - Storage Endpoints
    static let upload = "/v1/storage/upload"
    static let health = "/v1/health"
}
