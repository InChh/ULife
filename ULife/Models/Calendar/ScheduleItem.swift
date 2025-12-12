//
//  ScheduleItem.swift
//  ULife_Local
//
//  Created by 高煜尧 on 2025-12-09.
//

import Foundation
import UIKit
import UlifeLib

//struct ScheduleItem: Codable {
//    let id: Int64
//    let sourceId: Int64?          // 对应公共课的 source_id，可空
//    let courseName: String        // 课程名称
//    let teacherName: String?      // 授课老师
//    let location: String?         // 上课地点
//    let dayOfWeek: Int            // 1-7：周一到周日
//    let startSection: Int         // 起始节次
//    let endSection: Int           // 结束节次
//    let weeks: [Int]              // 上课周次列表
//    let type: CourseType?         // 课程类型：必修/选修
//    let credits: Int?             // 学分
//    let description: String?      // 课程描述
//    let colorHex: String          // 颜色 #RRGGBB
//    let isCustom: Bool            // 是否自定义日程
//
//    enum CourseType: String, Codable {
//        case compulsory
//        case elective
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case sourceId     = "source_id"
//        case courseName   = "course_name"
//        case teacherName  = "teacher_name"
//        case location
//        case dayOfWeek    = "day_of_week"
//        case startSection = "start_section"
//        case endSection   = "end_section"
//        case weeks
//        case type
//        case credits
//        case description
//        case colorHex     = "color_hex"
//        case isCustom     = "is_custom"
//    }
//}

extension ScheduleItem {
    /// 将课表项（包括自定义）转换为 UI 层的通用 Course
    /// - Parameters:
    ///   - sectionSlots: 节次对应的时间片，用于生成 timeRange
    ///   - fallbackColor: 颜色解析失败时的兜底色
    func toUICourse(sectionSlots: [Int: SectionSlot], fallbackColor: UIColor = .systemBlue) -> Course {
        let startText = sectionSlots[Int(startSection)]?.start ?? "第\(startSection)节"
        let endText = sectionSlots[Int(endSection)]?.end ?? "第\(endSection)节"
        let timeRange = "\(startText) - \(endText)"
        let uiColor = UIColor(hexString: colorHex) ?? fallbackColor
        let typeDisplay = type == "compulsory" ? "必修" : "选修"


        return Course(
            courseId: Int(id),
            name: courseName,
            timeRange: timeRange,
            startSection: startSection,
            endSection: endSection,
            location: location ?? "",
            teacher: teacherName ?? "",
            dayOfWeek: Int(dayOfWeek),
            typeDisplay: typeDisplay,
            credits: credits.map { Int($0) } ?? 0,
            descriptionText: description ?? "",
            color: uiColor
        )
    }
}

extension UIColor {
    /// 解析 #RRGGBB
    convenience init?(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard hex.count == 6, let value = Int(hex, radix: 16) else { return nil }
        let r = CGFloat((value >> 16) & 0xFF) / 255.0
        let g = CGFloat((value >> 8) & 0xFF) / 255.0
        let b = CGFloat(value & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

