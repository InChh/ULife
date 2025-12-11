//
//  DateExtention.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/2.
//  扩展 Date 类 把 创建时间（Date）转为"xx分钟前 / xx小时前 / xx天前"等字符串。

import Foundation

extension Date {
    func timeAgoString() -> String {
        let now = Date()
        let seconds = Int(now.timeIntervalSince(self))

        if seconds < 60 {
            return "\(seconds) 秒前"
        }

        let minutes = seconds / 60
        if minutes < 60 {
            return "\(minutes) 分钟前"
        }

        let hours = minutes / 60
        if hours < 24 {
            return "\(hours) 小时前"
        }

        let days = hours / 24
        if days < 7 {
            return "\(days) 天前"
        }

        let weeks = days / 7
        if weeks < 4 {
            return "\(weeks) 周前"
        }

        let months = days / 30
        if months < 12 {
            return "\(months) 个月前"
        }

        let years = days / 365
        return "\(years) 年前"
    }
}

// 扩展 String，支持 ISO8601 日期字符串
extension String {
    /// 将 ISO8601 日期字符串转换为相对时间描述
    func timeAgoString() -> String {
        // 尝试解析 ISO8601 格式的日期字符串
        let formatter = ISO8601DateFormatter()
        
        // 尝试带毫秒的格式
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: self) {
            return date.timeAgoString()
        }
        
        // 尝试不带毫秒的格式
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: self) {
            return date.timeAgoString()
        }
        
        // 如果解析失败，返回原字符串
        return self
    }
}
