//
//  UserManager.swift
//  ULife
//
//  Created by 赵文哲 on 6/12/2025.
//  用户管理逻辑

import Foundation

class UserManager {
    
    // MARK: - Singleton
    static let shared = UserManager()
    
    private init() {}
    
    // MARK: - Properties
    private let userDefaults = UserDefaults.standard
    private let userKey = "currentUser"
    private let settingsKey = "userSettings"
    
    // MARK: - User Management
    
    // 检查是否已登录
    var isLoggedIn: Bool {
        return getCurrentUser() != nil
    }
    
    // 获取当前用户
    func getCurrentUser() -> User? {
        guard let userData = userDefaults.data(forKey: userKey) else {
            return nil
        }
        
        do {
            let user = try JSONDecoder().decode(User.self, from: userData)
            return user
        } catch {
            print("解码用户数据失败: \(error)")
            return nil
        }
    }
    
    // 保存用户
    func saveUser(_ user: User) {
        do {
            let userData = try JSONEncoder().encode(user)
            userDefaults.set(userData, forKey: userKey)
            userDefaults.synchronize()
        } catch {
            print("编码用户数据失败: \(error)")
        }
    }
    
    // 清除用户数据（登出）
    func clearUser() {
        userDefaults.removeObject(forKey: userKey)
        userDefaults.synchronize()
    }
    
    // MARK: - Settings Management
    
    // 获取用户设置
    func getUserSettings() -> UserSettings {
        guard let settingsData = userDefaults.data(forKey: settingsKey) else {
            return UserSettings.default
        }
        
        do {
            let settings = try JSONDecoder().decode(UserSettings.self, from: settingsData)
            return settings
        } catch {
            print("解码用户设置失败: \(error)")
            return UserSettings.default
        }
    }
    
    // 保存用户设置
    func saveUserSettings(_ settings: UserSettings) {
        do {
            let settingsData = try JSONEncoder().encode(settings)
            userDefaults.set(settingsData, forKey: settingsKey)
            userDefaults.synchronize()
        } catch {
            print("编码用户设置失败: \(error)")
        }
    }
    
    // MARK: - Login/Logout
    
    // 登录（模拟）
    func login(studentId: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        // 这里模拟登录，实际项目中应该调用API
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if MockUserData.validateLogin(studentId: studentId, password: password) {
                if let user = MockUserData.currentUser {
                    self.saveUser(user)
                    completion(.success(user))
                } else {
                    completion(.failure(NSError(domain: "UserManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "用户不存在"])))
                }
            } else {
                completion(.failure(NSError(domain: "UserManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "学号或密码错误"])))
            }
        }
    }
    
    // 登出
    func logout() {
        clearUser()
        // 清除其他相关数据
        userDefaults.removeObject(forKey: "currentStudentId")
        userDefaults.removeObject(forKey: "isLoggedIn")
        userDefaults.synchronize()
    }
    
    // MARK: - Update User Info
    
    func updateUserInfo(_ updateRequest: UserUpdateRequest, completion: @escaping (Result<User, Error>) -> Void) {
        guard var currentUser = getCurrentUser() else {
            completion(.failure(NSError(domain: "UserManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "用户未登录"])))
            return
        }
        
        // 更新用户信息
        if let name = updateRequest.name {
            // 注意：实际项目中User应该是struct，需要重新创建
            // 这里简化处理
        }
        
        // 模拟更新成功
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.saveUser(currentUser)
            completion(.success(currentUser))
        }
    }
}
