//
//  Course.swift
//  ULife_Local
//
//  Created by 高煜尧 on 2025-12-06.
//

import Foundation
import UIKit

struct PublicCourse: Codable {
    let courseId: Int
    let courseName: String
    let teacherName: String
    let teacherId: Int
    let location: String
    let dayOfWeek: Int          // 1 = 周一
    let startSection: Int       // 例如 1 表示第 1 节
    let endSection: Int         // 例如 2 表示第 2 节
    let weeksRange: [Int]       // 例如 [1,2,...,16]
    let type: CourseType
    let credits: Int
    let description: String?


    enum CourseType: String, Codable {
        case compulsory
        case elective
    }


    enum CodingKeys: String, CodingKey {
        case courseId     = "course_id"
        case courseName   = "course_name"
        case teacherName  = "teacher_name"
        case teacherId    = "teacher_id"
        case location
        case dayOfWeek    = "day_of_week"
        case startSection = "start_section"
        case endSection   = "end_section"
        case weeksRange   = "weeks_range"
        case type
        case credits
        case description
    }
}

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
    func toUICourse(sectionSlots: [Int: SectionSlot], color: UIColor = .white) -> Course {
        let startText = sectionSlots[startSection]?.start ?? "第\(startSection)节"
        let endText = sectionSlots[endSection]?.end ?? "第\(endSection)节"
        let timeRange = "\(startText) - \(endText)"
        return Course(
            courseId: courseId,
            name: courseName,
            timeRange: timeRange,
            location: location,
            teacher: teacherName,
            dayOfWeek: dayOfWeek,
            typeDisplay: type == .compulsory ? "必修" : "选修",
            credits: credits,
            descriptionText: description ?? "",
            color: color
        )
    }

    /// 判断是否在指定周次与星期几
    func isIn(week: Int, dayOfWeek targetDay: Int) -> Bool {
        return dayOfWeek == targetDay && weeksRange.contains(week)
    }
}








