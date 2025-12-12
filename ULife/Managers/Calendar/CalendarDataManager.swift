//
//  CalendarDataManager.swift
//  ULife_Local
//
//  Created by 高煜尧 on 2025-12-06.
//

import Foundation
import UlifeLib
import UIKit

final class CalendarDataManager {
    static let shared = CalendarDataManager()
    private init() {}

    /// mock 全校课程
    private func mockPublicCourses() -> [PublicCourse] {
        return [
            PublicCourse(id: 1,
                         courseName: "高等数学（上）",
                         teacherName: "王教授",
                         teacherId: 1001,
                         location: "教二-201",
                         dayOfWeek: 1,
                         startSection: 1,
                         endSection: 2,
                         weeksRange: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
                         type: "compulsory",
                         credits: 4,
                         description: "必修课，微积分基础"),
            PublicCourse(id: 2,
                         courseName: "大学英语 II",
                         teacherName: "李老师",
                         teacherId: 1002,
                         location: "外语楼-105",
                         dayOfWeek: 1,
                         startSection: 3,
                         endSection: 4,
                         weeksRange: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
                         type: "compulsory",
                         credits: 3,
                         description: "必修课，英语综合训练"),
            PublicCourse(id: 3,
                         courseName: "计算机网络",
                         teacherName: "赵老师",
                         teacherId: 1003,
                         location: "综教-302",
                         dayOfWeek: 3,
                         startSection: 5,
                         endSection: 6,
                         weeksRange: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
                         type: "elective",
                         credits: 3,
                         description: "选修课，网络基础与协议"),
            PublicCourse(id: 4,
                         courseName: "线性代数",
                         teacherName: "张老师",
                         teacherId: 1004,
                         location: "教三-101",
                         dayOfWeek: 4,
                         startSection: 1,
                         endSection: 2,
                         weeksRange: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
                         type: "compulsory",
                         credits: 3,
                         description: "必修课，矩阵与向量空间"),
            PublicCourse(id: 5,
                         courseName: "体育（羽毛球）",
                         teacherName: "李教练",
                         teacherId: 1005,
                         location: "体育馆-2",
                         dayOfWeek: 5,
                         startSection: 3,
                         endSection: 4,
                         weeksRange: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
                         type: "elective",
                         credits: 1,
                         description: "选修课，体育锻炼")
        ]
    }
    
    // mock 学生课表
    private func mockSchedule(week: Int) -> [ScheduleItem] {
            return [
                ScheduleItem(
                    id: 1,
                    sourceId: 1,
                    courseName: "高等数学（上）",
                    teacherName: "王教授",
                    location: "外语楼-105",
                    dayOfWeek: 1,
                    startSection: 3,
                    endSection: 4,
                    weeks: Array(1...16),
                    type: "compulsory",
                    credits: 4,
                    description: "必修课，微积分基础",
                    colorHex: "#4A90E2",
                    isCustom: false),
                ScheduleItem(
                    id: 2,
                    sourceId: 2,
                    courseName: "大学英语 II",
                    teacherName: "李老师",
                    location: "教二-201",
                    dayOfWeek: 2,
                    startSection: 1,
                    endSection: 2,
                    weeks: Array(1...16),
                    type: "compulsory",
                    credits: 3,
                    description: "必修课，英语综合训练",
                    colorHex: "#F5A623",
                    isCustom: false)
        ]
    }

    // mock 学期信息
    private func mockSemesters() -> [Semester] {
        return [
            Semester(
                id: 1,
                name: "2024-2025 第一学期",
                startDate: "2024-09-02",
                endDate: "2025-01-10",
                isCurrent: true
            ),
            Semester(
                id: 2,
                name: "2024-2025 第二学期",
                startDate: "2025-02-24",
                endDate: "2025-07-05",
                isCurrent: false
            )
        ]
    }

    // MARK: 公共课库
    func fetchPublicCourses(useMock: Bool = true, completion: @escaping ([PublicCourse]) -> Void) {
        if useMock {
            completion(mockPublicCourses())
        } else {
            // TODO: 替换为真实接口调用
            completion([])
        }
    }

    // MARK: 个人课表
    func fetchSchedule(useMock: Bool = true,
                       semesterId: Int = 0,
                       week: Int = 1,
                       completion: @escaping ([ScheduleItem]) -> Void) {
        if useMock {
            completion(mockSchedule(week: week))
        } else {
            // TODO: 替换为真实接口调用
            completion([])
        }
    }

    // MARK: 学期
    func fetchSemesters(useMock: Bool = true, completion: @escaping ([Semester]) -> Void) {
        if useMock {
            completion(mockSemesters())
        } else {
            // TODO: 替换为真实接口调用
            completion([])
        }
    }

}



