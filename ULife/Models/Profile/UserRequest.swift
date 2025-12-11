//
//  UserRequest.swift
//  ULife
//
//  Created on 2025/12/11.
//  用户API请求

import Foundation

// MARK: - Response Models

// 登录响应
struct LoginResponse: Codable {
    let token: String
    let user: UserInfo
}

// 用户信息（后端返回格式）
struct UserInfo: Codable {
    let id: String
    let student_id: String
    let name: String
    let avatar_url: String?
    let role: String
    let college: String
    let major: String
    let grade: String?
    let class_name: String?
    let bio: String?
    let phone: String?
    let email: String?
    let wechat_id: String?
    let weekly_course_count: Int
    let forum_activity_score: Int
    let collection_count: Int
    let setting_privacy_course: String
    let setting_notification_switch: Bool
    
    // 转换为客户端 User 模型
    func toUser() -> User {
        return User(
            id: id,
            studentId: student_id,
            username: student_id,
            password: "", // 不存储密码
            name: name,
            avatar: avatar_url,
            college: college,
            major: major,
            grade: grade ?? "未设置",
            className: class_name ?? "未设置",
            email: email ?? "",
            phone: phone ?? "",
            qq: nil,
            wechat: wechat_id,
            bio: bio,
            joinDate: Date(), // 后端未返回，使用当前时间
            lastLogin: Date()
        )
    }
}

// 注册响应
struct RegisterResponse: Codable {
    let user_id: String
}

// 修改密码请求
struct ChangePasswordRequest: Codable {
    let old_password: String
    let new_password: String
}

// MARK: - User Request Class
class UserRequest {
    private let networkManager = NetworkManager.shared
    
    // MARK: - Login
    func login(studentId: String, password: String) async throws -> (String, User) {
        let request = LoginRequest(studentId: studentId, password: password)
        let response: LoginResponse = try await networkManager.request(
            endpoint: APIEndpoints.login,
            method: .post,
            body: request
        )
        
        // 保存 token
        networkManager.setAuthToken(response.token)
        
        // 转换为 User 模型
        let user = response.user.toUser()
        
        return (response.token, user)
    }
    
    // MARK: - Register
    func register(request: RegisterRequest) async throws -> String {
        let response: RegisterResponse = try await networkManager.request(
            endpoint: APIEndpoints.register,
            method: .post,
            body: request
        )
        return response.user_id
    }
    
    // MARK: - Get Current User Info
    func getCurrentUserInfo() async throws -> User {
        let response: UserInfo = try await networkManager.request(
            endpoint: APIEndpoints.userMe,
            method: .get
        )
        return response.toUser()
    }
    
    // MARK: - Update Profile
    func updateProfile(request: UserUpdateRequest) async throws {
        // 创建符合后端格式的请求体
        struct BackendUpdateRequest: Codable {
            let name: String?
            let avatar_url: String?
            let bio: String?
            let phone: String?
            let email: String?
            let wechat_id: String?
        }
        
        let backendRequest = BackendUpdateRequest(
            name: request.name,
            avatar_url: request.avatar,
            bio: request.bio,
            phone: request.phone,
            email: request.email,
            wechat_id: request.wechat
        )
        
        try await networkManager.requestWithoutData(
            endpoint: APIEndpoints.userMe,
            method: .put,
            body: backendRequest
        )
    }
    
    // MARK: - Change Password
    func changePassword(oldPassword: String, newPassword: String) async throws {
        let request = ChangePasswordRequest(
            old_password: oldPassword,
            new_password: newPassword
        )
        
        try await networkManager.requestWithoutData(
            endpoint: APIEndpoints.changePassword,
            method: .post,
            body: request
        )
    }
    
    // MARK: - Logout
    func logout() async throws {
        try await networkManager.requestWithoutData(
            endpoint: APIEndpoints.logout,
            method: .post
        )
        
        // 清除本地 token
        networkManager.clearAuthToken()
    }
}

