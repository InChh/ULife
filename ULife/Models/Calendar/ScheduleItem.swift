//
//  ScheduleItem.swift
//  ULife_Local
//
//  Created by 高煜尧 on 2025-12-09.
//

import Foundation
import UIKit

struct ScheduleItem: Codable {
    let id: Int64
    let sourceId: Int64?          // 对应公共课的 source_id，可空
    let courseName: String        // 课程名称
    let teacherName: String?      // 授课老师
    let location: String?         // 上课地点
    let dayOfWeek: Int            // 1-7：周一到周日
    let startSection: Int         // 起始节次
    let endSection: Int           // 结束节次
    let weeks: [Int]              // 上课周次列表
    let type: CourseType?         // 课程类型：必修/选修
    let credits: Int?             // 学分
    let description: String?      // 课程描述
    let colorHex: String          // 颜色 #RRGGBB
    let isCustom: Bool            // 是否自定义日程

    enum CourseType: String, Codable {
        case compulsory
        case elective
    }

    enum CodingKeys: String, CodingKey {
        case id
        case sourceId     = "source_id"
        case courseName   = "course_name"
        case teacherName  = "teacher_name"
        case location
        case dayOfWeek    = "day_of_week"
        case startSection = "start_section"
        case endSection   = "end_section"
        case weeks
        case type
        case credits
        case description
        case colorHex     = "color_hex"
        case isCustom     = "is_custom"
    }
}

// 扩展方法已移除，新版 CalendarViewController 直接使用 ScheduleItem

