//
//  ScheduleItem.swift
//  ULife_Local
//
//  Created by 高煜尧 on 2025-12-09.
//

import Foundation
import UIKit
import UlifeLib


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
            startSection: Int(startSection),
            endSection: Int(endSection),
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

