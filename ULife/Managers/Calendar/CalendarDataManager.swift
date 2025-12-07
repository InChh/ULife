//
//  CalendarDataManager.swift
//  ULife_Local
//
//  Created by 高煜尧 on 2025-12-06.
//

import Foundation

/// 日历数据管理器（当前提供 mock，后续可替换为 Protobuf/网络）
final class CalendarDataManager {
    static let shared = CalendarDataManager()
    private init() {}


    /// 获取全校课程（mock）
    func fetchPublicCoursesMock() -> [PublicCourse] {
        return [
            PublicCourse(courseId: 1, 
                         courseName: "高等数学（上）",
                         teacherName: "王教授",
                         teacherId: 1001,
                         location: "教二-201",
                         dayOfWeek: 1,
                         startSection: 1,
                         endSection: 2,
                         weeksRange: Array(1...16),
                         type: .compulsory,
                         credits: 4,
                         description: "必修课，微积分基础"),
            PublicCourse(courseId: 2, 
                         courseName: "大学英语 II",
                         teacherName: "李老师",
                         teacherId: 1002,
                         location: "外语楼-105",
                         dayOfWeek: 1,
                         startSection: 3,
                         endSection: 4,
                         weeksRange: Array(1...16),
                         type: .compulsory,
                         credits: 3,
                         description: "必修课，英语综合训练"),
            PublicCourse(courseId: 3, 
                         courseName: "计算机网络",
                         teacherName: "赵老师",
                         teacherId: 1003,
                         location: "综教-302",
                         dayOfWeek: 3,
                         startSection: 5,
                         endSection: 6,
                         weeksRange: Array(1...16),
                         type: .elective,
                         credits: 3,
                         description: "选修课，网络基础与协议"),
            PublicCourse(courseId: 4, 
                         courseName: "线性代数",
                         teacherName: "张老师",
                         teacherId: 1004,
                         location: "教三-101",
                         dayOfWeek: 4,
                         startSection: 1,
                         endSection: 2,
                         weeksRange: Array(1...16),
                         type: .compulsory,
                         credits: 3,
                         description: "必修课，矩阵与向量空间"),
            PublicCourse(courseId: 5, 
                         courseName: "体育（羽毛球）",
                         teacherName: "李教练",
                         teacherId: 1005,
                         location: "体育馆-2",
                         dayOfWeek: 5,
                         startSection: 3,
                         endSection: 4,
                         weeksRange: Array(1...16),
                         type: .elective,
                         credits: 1,
                         description: "选修课，体育锻炼")
        ]
    }
}



