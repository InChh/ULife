//
//  UserSettings.swift
//  ULife
//
//  Created by 赵文哲 on 6/12/2025.
//  用户设置模型

import Foundation

struct UserSettings: Codable {
    // 通知设置
    var classReminder: Bool = true
    var classReminderTime: Int = 15 // 分钟
    var forumReplyNotification: Bool = true
    var systemNotification: Bool = true
    
    // 隐私设置
    var scheduleVisibility: ScheduleVisibility = .classmatesOnly
    var allowPrivateMessages: Bool = true
    var showPhoneNumber: Bool = false
    
    // 主题设置
    var theme: AppTheme = .system
    var fontSize: FontSize = .medium
    
    // 数据统计设置
    var showLearningStats: Bool = true
    
    enum ScheduleVisibility: String, Codable, CaseIterable {
        case `private` = "仅自己"
        case classmatesOnly = "同班同学"
        case allUsers = "所有人"
    }
    
    enum AppTheme: String, Codable, CaseIterable {
        case light = "浅色模式"
        case dark = "深色模式"
        case system = "跟随系统"
    }
    
    enum FontSize: String, Codable, CaseIterable {
        case small = "小"
        case medium = "中"
        case large = "大"
        case extraLarge = "特大"
    }
    
    // 默认设置
    static let `default` = UserSettings()
}
