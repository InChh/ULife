//
//  CalendarRequest.swift
//  ULife
//
//  Created on 2025/12/11.
//  课表API请求

import Foundation

// MARK: - Response Models

// 学期响应
struct SemestersResponse: Codable {
    let semesters: [Semester]
}

// 学期信息
struct Semester: Codable {
    let id: Int
    let name: String
    let start_date: String
    let end_date: String
    let is_current: Bool
}

// 公共课程列表响应
struct PublicCoursesResponse: Codable {
    let list: [PublicCourseDTO]
    let pagination: PaginationDTO
}

// 分页信息DTO
struct PaginationDTO: Codable {
    let total: Int64
    let page: Int
    let page_size: Int
    let pages: Int
    
    // 转换为客户端 Pagination 模型
    func toPagination() -> Pagination {
        return Pagination(
            page: page,
            pages: pages,
            pageSize: page_size,
            total: Int(total)
        )
    }
}

// 公共课程DTO（后端格式）
struct PublicCourseDTO: Codable {
    let id: Int64
    let course_name: String
    let teacher_name: String
    let teacher_id: Int64?
    let location: String
    let day_of_week: Int
    let start_section: Int
    let end_section: Int
    let weeks_range: String?  // JSON字符串，如 "[1,2,3,4,5]"
    let type: String
    let credits: Int
    let description: String?
    let semester_id: Int
    
    // 转换为客户端 PublicCourse 模型
    func toPublicCourse() -> PublicCourse {
        // 解析 weeks_range JSON 字符串
        var weeks: [Int] = []
        if let weeksStr = weeks_range,
           let data = weeksStr.data(using: .utf8),
           let weeksArray = try? JSONDecoder().decode([Int].self, from: data) {
            weeks = weeksArray
        }
        
        let courseType: PublicCourse.CourseType = type == "compulsory" ? .compulsory : .elective
        
        return PublicCourse(
            courseId: Int(id),
            courseName: course_name,
            teacherName: teacher_name,
            teacherId: Int(teacher_id ?? 0),
            location: location,
            dayOfWeek: day_of_week,
            startSection: start_section,
            endSection: end_section,
            weeksRange: weeks,
            type: courseType,
            credits: credits,
            description: description
        )
    }
}

// 用户课表响应
struct UserScheduleResponse: Codable {
    let items: [ScheduleItemDTO]
}

// 评论列表响应（论坛模块可能用到）
struct CommentsListResponseDTO: Codable {
    let list: [CommentDTO]
    let pagination: PaginationDTO
}

struct CommentDTO: Codable {
    // 这里可以定义评论的字段，暂时留空
}

// 课表项DTO（后端格式）
struct ScheduleItemDTO: Codable {
    let id: Int64
    let source_id: Int64?
    let course_name: String
    let teacher_name: String?
    let location: String?
    let day_of_week: Int
    let start_section: Int
    let end_section: Int
    let weeks_range: String?  // JSON字符串
    let type: String?
    let credits: Int?
    let description: String?
    let color_hex: String
    let is_custom: Bool
    
    // 转换为客户端 ScheduleItem 模型
    func toScheduleItem() -> ScheduleItem {
        // 解析 weeks_range JSON 字符串
        var weeks: [Int] = []
        if let weeksStr = weeks_range,
           let data = weeksStr.data(using: .utf8),
           let weeksArray = try? JSONDecoder().decode([Int].self, from: data) {
            weeks = weeksArray
        }
        
        var courseType: ScheduleItem.CourseType? = nil
        if let typeStr = type {
            courseType = typeStr == "compulsory" ? .compulsory : .elective
        }
        
        return ScheduleItem(
            id: id,
            sourceId: source_id,
            courseName: course_name,
            teacherName: teacher_name,
            location: location,
            dayOfWeek: day_of_week,
            startSection: start_section,
            endSection: end_section,
            weeks: weeks,
            type: courseType,
            credits: credits,
            description: description,
            colorHex: color_hex,
            isCustom: is_custom
        )
    }
}

// 添加课表项请求
struct AddScheduleItemRequest: Codable {
    let source_id: Int64?
    let semester_id: Int
    let course_name: String
    let teacher_name: String?
    let location: String?
    let day_of_week: Int
    let start_section: Int
    let end_section: Int
    let weeks: [Int]
    let type: String?
    let credits: Int?
    let description: String?
    let color_hex: String
    let is_custom: Bool
}

// 批量添加课表项请求
struct AddScheduleItemsRequest: Codable {
    let items: [AddScheduleItemRequest]
}

// 批量添加响应
struct AddScheduleItemsResponse: Codable {
    let successful_items: [ScheduleItemDTO]
    let failed_items: [FailedItemDTO]
}

struct FailedItemDTO: Codable {
    let course_name: String
    let error_message: String
}

// MARK: - Calendar Request Class
class CalendarRequest {
    private let networkManager = NetworkManager.shared
    
    // MARK: - Get Semesters
    func getSemesters() async throws -> [Semester] {
        let response: SemestersResponse = try await networkManager.request(
            endpoint: APIEndpoints.semesters,
            method: .get
        )
        return response.semesters
    }
    
    // MARK: - Get Public Courses
    func getPublicCourses(
        semesterId: Int? = nil,
        name: String? = nil,
        teacher: String? = nil,
        page: Int = 1,
        pageSize: Int = 20
    ) async throws -> ([PublicCourse], Pagination) {
        var params: [String: Any] = [
            "page": page,
            "pageSize": pageSize
        ]
        
        if let semesterId = semesterId {
            params["semester_id"] = semesterId
        }
        if let name = name {
            params["name"] = name
        }
        if let teacher = teacher {
            params["teacher"] = teacher
        }
        
        let response: PublicCoursesResponse = try await networkManager.request(
            endpoint: APIEndpoints.publicCourses,
            method: .get,
            parameters: params
        )
        
        let courses = response.list.map { $0.toPublicCourse() }
        let pagination = response.pagination.toPagination()
        return (courses, pagination)
    }
    
    // MARK: - Get User Schedule
    func getUserSchedule(semesterId: Int, week: Int? = nil) async throws -> [ScheduleItem] {
        var params: [String: Any] = [
            "semester_id": semesterId
        ]
        
        if let week = week {
            params["week"] = week
        }
        
        let response: UserScheduleResponse = try await networkManager.request(
            endpoint: APIEndpoints.schedule,
            method: .get,
            parameters: params
        )
        
        return response.items.map { $0.toScheduleItem() }
    }
    
    // MARK: - Add Schedule Items
    func addScheduleItems(items: [AddScheduleItemRequest]) async throws -> AddScheduleItemsResponse {
        let request = AddScheduleItemsRequest(items: items)
        
        let response: AddScheduleItemsResponse = try await networkManager.request(
            endpoint: APIEndpoints.schedule,
            method: .post,
            body: request
        )
        
        return response
    }
    
    // MARK: - Delete Schedule Item
    func deleteScheduleItem(itemId: Int64) async throws {
        let params: [String: Any] = ["item_id": itemId]
        
        try await networkManager.requestWithoutData(
            endpoint: APIEndpoints.schedule,
            method: .delete,
            parameters: params
        )
    }
    
    // MARK: - Update Schedule Item
    func updateScheduleItem(
        itemId: Int64,
        courseName: String? = nil,
        teacherName: String? = nil,
        location: String? = nil,
        colorHex: String? = nil,
        description: String? = nil
    ) async throws -> ScheduleItem {
        struct UpdateRequest: Codable {
            let course_name: String?
            let teacher_name: String?
            let location: String?
            let color_hex: String?
            let description: String?
        }
        
        let request = UpdateRequest(
            course_name: courseName,
            teacher_name: teacherName,
            location: location,
            color_hex: colorHex,
            description: description
        )
        
        let params: [String: Any] = ["item_id": itemId]
        
        let response: ScheduleItemDTO = try await networkManager.request(
            endpoint: APIEndpoints.schedule,
            method: .patch,
            parameters: params,
            body: request
        )
        
        return response.toScheduleItem()
    }
}

