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


// 扩展方法已移除，新版 CalendarViewController 直接使用 ScheduleItem








