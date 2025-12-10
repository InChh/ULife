//
//  CourseRemainderManager.swift
//  ULife_Local
//
//  Created by 高煜尧 on 2025-12-10.
//

import Foundation
import UserNotifications
import UIKit

final class CourseReminderManager {
    static let shared = CourseReminderManager()
    private init() {}

    /// 请求通知权限，已授权则直接回调 true
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                completion(true)
            case .denied:
                completion(false)
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    completion(granted)
                }
            default:
                completion(false)
            }
        }
    }

    func enableReminder(for course: Course, sectionSlots: [Int: SectionSlot], leadMinutes: Int = 10) {
        guard let comps = reminderComponents(for: course, sectionSlots: sectionSlots, leadMinutes: leadMinutes) else { return }
        let content = UNMutableNotificationContent()
        content.title = "上课提醒：\(course.name)"
        content.body = "\(course.timeRange) @ \(course.location.isEmpty ? "教室待定" : course.location)"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(identifier: reminderId(for: course), content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        markEnabled(true, for: course)
        storeLeadMinutes(leadMinutes, for: course)
    }

    func disableReminder(for course: Course) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderId(for: course)])
        markEnabled(false, for: course)
    }

    func isReminderEnabled(for course: Course) -> Bool {
        return UserDefaults.standard.bool(forKey: reminderId(for: course))
    }

    func leadMinutes(for course: Course) -> Int {
        let value = UserDefaults.standard.integer(forKey: leadMinutesKey(for: course))
        return value > 0 ? value : 10
    }

    private func reminderId(for course: Course) -> String {
        return "course-\(course.courseId)-\(course.dayOfWeek)-\(course.startSection)"
    }

    private func reminderComponents(for course: Course, sectionSlots: [Int: SectionSlot], leadMinutes: Int) -> DateComponents? {
        guard let startText = sectionSlots[course.startSection]?.start else { return nil }
        let parts = startText.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return nil }

        // iOS weekday: 1=周日, 2=周一... 如果课程是 1=周一，则转换
        let iosWeekday = ((course.dayOfWeek % 7) + 1)
        var hour = parts[0]
        var minute = parts[1] - leadMinutes
        if minute < 0 {
            minute += 60
            hour -= 1
        }
        guard hour >= 0 else { return nil }

        var comps = DateComponents()
        comps.weekday = iosWeekday
        comps.hour = hour
        comps.minute = minute
        return comps
    }

    private func markEnabled(_ enabled: Bool, for course: Course) {
        UserDefaults.standard.set(enabled, forKey: reminderId(for: course))
    }


    private func storeLeadMinutes(_ minutes: Int, for course: Course) {
        UserDefaults.standard.set(minutes, forKey: leadMinutesKey(for: course))
    }


    private func leadMinutesKey(for course: Course) -> String {
        return "course-lead-\(course.courseId)-\(course.dayOfWeek)-\(course.startSection)"
    }
}
