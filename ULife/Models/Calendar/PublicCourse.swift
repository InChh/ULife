//
//  Course.swift
//  ULife_Local
//
//  Created by 高煜尧 on 2025-12-06.
//

import Foundation
import UIKit
import UlifeLib

/// 节次对应的时间段，用于生成展示用的 timeRange
struct SectionSlot {
    let start: String
    let end: String
}


extension PublicCourse {
    /// 将 PublicCourse 转为 UI 层的 Course（沿用日历界面的 Course 结构）
    /// - Parameters:
    ///   - sectionSlots: 节次时间表，例如 [1: SectionSlot(start: "08:00", end: "08:45")]
    ///   - color: UI 颜色（默认白色，可按类型/冲突染色）
    func toUICourse(sectionSlots: [Int: SectionSlot]) -> Course {
        let startText = sectionSlots[Int(startSection)]?.start ?? "第\(startSection)节"
        let endText = sectionSlots[Int(endSection)]?.end ?? "第\(endSection)节"
        let timeRange = "\(startText) - \(endText)"
        return Course(
            courseId: Int(id),
            name: courseName,
            timeRange: timeRange,
            startSection: Int(startSection),
            endSection: Int(endSection),
            location: location,
            teacher: teacherName,
            dayOfWeek: Int(dayOfWeek),
            typeDisplay: type == "compulsory" ? "必修" : "选修",
            credits: Int(credits),
            descriptionText: description ?? "",
            color: .white
        )
    }

    /// 判断是否在指定周次与星期几
    func isIn(week: Int, dayOfWeek targetDay: Int) -> Bool {
        return dayOfWeek == targetDay && weeksRange.contains(Int32(week))
    }
}








