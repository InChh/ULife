//
//  User.swift
//  ULife
//
//  Created by 赵文哲 on 6/12/2025.
//  用户数据模型

import Foundation

struct User: Codable {
    let id: String
    let studentId: String          // 学号
    let username: String           // 用户名
    let password: String           // 密码（实际项目中应加密存储）
    let name: String               // 真实姓名
    let avatar: String?            // 头像URL
    let college: String            // 学院
    let major: String              // 专业
    let grade: String              // 年级
    let className: String          // 班级
    let email: String              // 邮箱
    let phone: String              // 手机号
    let qq: String?                // QQ号
    let wechat: String?            // 微信号
    let bio: String?               // 个人简介
    let joinDate: Date             // 注册时间
    let lastLogin: Date            // 最后登录时间
    
    // 计算属性：显示名称
    var displayName: String {
        return name.isEmpty ? username : name
    }
    
    // 计算属性：完整学籍信息
    var academicInfo: String {
        return "\(college) · \(major) · \(grade)级"
    }
}

// 登录请求模型
struct LoginRequest: Codable {
    let studentId: String
    let password: String
}

// 注册请求模型
struct RegisterRequest: Codable {
    let studentId: String
    let password: String
    let name: String
    let college: String
    let major: String
    let grade: String
    let className: String
    let email: String
    let phone: String
}

// 用户信息更新模型
struct UserUpdateRequest: Codable {
    let name: String?
    let avatar: String?
    let bio: String?
    let qq: String?
    let wechat: String?
    let email: String?
    let phone: String?
}
