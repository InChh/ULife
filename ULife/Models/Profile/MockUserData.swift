//
//  MockUserData.swift
//  ULife
//
//  Created by 赵文哲 on 6/12/2025.
//  模拟用户数据

import Foundation

struct MockUserData {
    // 当前登录用户（模拟数据）
    static var currentUser: User? = {
        return User(
            id: "1",
            studentId: "12345678",
            username: "student01",
            password: "password",
            name: "张三",
            avatar: "https://randomuser.me/api/portraits/men/32.jpg",
            college: "字节跳动大学",
            major: "计算机工程",
            grade: "2025",
            className: "计算机工程某班",
            email: "zhangsan@example.com",
            phone: "13800138000",
            qq: "12345678",
            wechat: "zhangsan_wechat",
            bio: "热爱编程，喜欢篮球，期待和大家一起进步！",
            joinDate: Date(timeIntervalSinceNow: -86400 * 100), // 100天前
            lastLogin: Date()
        )
    }()
    
    // 模拟用户设置
    static var userSettings: UserSettings = UserSettings.default
    
    // 模拟用户统计信息
    static var userStats: UserStats = UserStats.defaultStats
    
    // 模拟登录验证
    static func validateLogin(studentId: String, password: String) -> Bool {
        // 模拟验证逻辑
        return studentId == "12345678" && password == "password"
    }
    
    // 模拟注册
    static func register(_ request: RegisterRequest) -> Bool {
        // 模拟注册逻辑
        print("注册信息: \(request)")
        return true
    }
}

// 用户统计信息
struct UserStats {
    let weeklyClasses: Int
    let monthlyPosts: Int
    let monthlyComments: Int
    let savedCourses: Int
    let savedPosts: Int
    let loginDays: Int
    
    static let defaultStats = UserStats(
        weeklyClasses: 24,
        monthlyPosts: 12,
        monthlyComments: 45,
        savedCourses: 8,
        savedPosts: 23,
        loginDays: 98
    )
}
