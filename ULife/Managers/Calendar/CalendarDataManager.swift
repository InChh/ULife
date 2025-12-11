//
//  CalendarDataManager.swift
//  ULife_Local
//
//  Created by 高煜尧 on 2025-12-06.
//  Updated on 2025-12-11: 改用真实网络请求

import Foundation

/// 日历数据管理器
final class CalendarDataManager {
    static let shared = CalendarDataManager()
    private let calendarRequest = CalendarRequest()
    
    private init() {}

    /// 获取学期列表
    func fetchSemesters() async throws -> [Semester] {
        return try await calendarRequest.getSemesters()
    }

    /// 获取全校公共课程
    func fetchPublicCourses(
        semesterId: Int? = nil,
        name: String? = nil,
        teacher: String? = nil,
        page: Int = 1,
        pageSize: Int = 20
    ) async throws -> ([PublicCourse], Pagination) {
        return try await calendarRequest.getPublicCourses(
            semesterId: semesterId,
            name: name,
            teacher: teacher,
            page: page,
            pageSize: pageSize
        )
    }
    
    /// 获取用户课表
    func fetchSchedule(semesterId: Int, week: Int? = nil) async throws -> [ScheduleItem] {
        return try await calendarRequest.getUserSchedule(
            semesterId: semesterId,
            week: week
        )
    }
    
    /// 添加课表项
    func addScheduleItems(items: [AddScheduleItemRequest]) async throws -> AddScheduleItemsResponse {
        return try await calendarRequest.addScheduleItems(items: items)
    }
    
    /// 删除课表项
    func deleteScheduleItem(itemId: Int64) async throws {
        try await calendarRequest.deleteScheduleItem(itemId: itemId)
    }
    
    /// 更新课表项
    func updateScheduleItem(
        itemId: Int64,
        courseName: String? = nil,
        teacherName: String? = nil,
        location: String? = nil,
        colorHex: String? = nil,
        description: String? = nil
    ) async throws -> ScheduleItem {
        return try await calendarRequest.updateScheduleItem(
            itemId: itemId,
            courseName: courseName,
            teacherName: teacherName,
            location: location,
            colorHex: colorHex,
            description: description
        )
    }
    
    // MARK: - Mock方法（已废弃，仅供调试）
    @available(*, deprecated, message: "请使用 fetchPublicCourses 方法")
    func fetchPublicCoursesMock() -> [PublicCourse] {
        return []
    }
    
    @available(*, deprecated, message: "请使用 fetchSchedule 方法")
    func fetchScheduleMock() -> [ScheduleItem] {
        return []
        }
}
