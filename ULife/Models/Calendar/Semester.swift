//
//  Semester.swift
//  ULife_Local
//
//  Created by 高煜尧 on 2025-12-11.
//

import Foundation
import UlifeLib

extension Semester {
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
