//
//  Semester.swift
//  ULife_Local
//
//  Created by 高煜尧 on 2025-12-11.
//

import Foundation

/// 学期模型，对应 proto 的 Semester
struct Semester: Codable {
    let id: Int64
    let name: String
    let startDate: String   // yyyy-MM-dd
    let endDate: String
    let isCurrent: Bool


    enum CodingKeys: String, CodingKey {
        case id
        case name
        case startDate = "start_date"
        case endDate   = "end_date"
        case isCurrent = "is_current"
    }


    /// 根据 start_date 计算当前周次（最少返回 1）
    func currentWeek(now: Date = Date(), calendar: Calendar = .current) -> Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        guard let start = formatter.date(from: startDate) else { return nil }
        let days = calendar.dateComponents([.day], from: start, to: now).day ?? 0
        return max(1, days / 7 + 1)
    }
}
