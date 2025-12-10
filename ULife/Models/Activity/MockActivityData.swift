//
//  MockActivityData.swift
//  ULife
//
//  Created on 2025/12/1.
//

import Foundation

/// 活动模块 Mock 数据
struct MockActivityData {
    
    /// Mock 活动列表数据
    static var activities: [ActivityListItem] = [
        ActivityListItem(
            id: "1",
            title: "校园音乐节",
            coverUrl: "https://example.com/images/music_festival.jpg",
            location: "学校大礼堂",
            startTime: Date(timeIntervalSinceNow: 86400 * 7), // 7天后
            quota: 500,
            currentEnrollments: 320
        ),
        ActivityListItem(
            id: "2",
            title: "学术讲座：人工智能前沿技术",
            coverUrl: "https://example.com/images/ai_lecture.jpg",
            location: "学术报告厅",
            startTime: Date(timeIntervalSinceNow: 86400 * 3), // 3天后
            quota: 200,
            currentEnrollments: 180
        ),
        ActivityListItem(
            id: "3",
            title: "篮球社团招新活动",
            coverUrl: "https://example.com/images/basketball.jpg",
            location: "体育馆",
            startTime: Date(timeIntervalSinceNow: 86400 * 5), // 5天后
            quota: 50,
            currentEnrollments: 35
        ),
        ActivityListItem(
            id: "4",
            title: "编程竞赛：算法挑战赛",
            coverUrl: "https://example.com/images/coding_contest.jpg",
            location: "计算机实验室",
            startTime: Date(timeIntervalSinceNow: 86400 * 10), // 10天后
            quota: 100,
            currentEnrollments: 95
        ),
        ActivityListItem(
            id: "5",
            title: "环保主题讲座",
            coverUrl: "https://example.com/images/environment.jpg",
            location: "教学楼A101",
            startTime: Date(timeIntervalSinceNow: 86400 * 2), // 2天后
            quota: 150,
            currentEnrollments: 120
        )
    ]
    
    /// Mock 活动详情数据
    static func getActivityDetail(id: String) -> Activity? {
        let details: [String: Activity] = [
            "1": Activity(
                id: "1",
                title: "校园音乐节",
                content: "一年一度的校园音乐节即将开幕！本次音乐节将邀请多位知名音乐人和校园乐队参与演出，为大家带来精彩的音乐盛宴。活动包括：\n1. 开幕式演出\n2. 校园乐队比赛\n3. 音乐工作坊\n4. 闭幕式音乐会\n\n欢迎所有热爱音乐的同学参加！",
                coverUrl: "https://example.com/images/music_festival.jpg",
                activityType: .club,
                location: "学校大礼堂",
                organizer: "学生会文艺部",
                startTime: Date(timeIntervalSinceNow: 86400 * 7),
                endTime: Date(timeIntervalSinceNow: 86400 * 7 + 3600 * 3), // 3小时后结束
                quota: 500,
                currentEnrollments: 320,
                needSignIn: true,
                status: .published,
                createdAt: Date(timeIntervalSinceNow: -86400 * 10),
                isEnrolled: false,
                isCollected: false
            ),
            "2": Activity(
                id: "2",
                title: "学术讲座：人工智能前沿技术",
                content: "本次讲座将深入探讨人工智能领域的最新发展，包括：\n- 大语言模型的最新进展\n- 计算机视觉技术应用\n- 机器学习在医疗领域的应用\n- AI伦理与未来发展\n\n主讲人：张教授（计算机学院）",
                coverUrl: "https://example.com/images/ai_lecture.jpg",
                activityType: .lecture,
                location: "学术报告厅",
                organizer: "计算机学院",
                startTime: Date(timeIntervalSinceNow: 86400 * 3),
                endTime: Date(timeIntervalSinceNow: 86400 * 3 + 3600 * 2),
                quota: 200,
                currentEnrollments: 180,
                needSignIn: false,
                status: .published,
                createdAt: Date(timeIntervalSinceNow: -86400 * 5),
                isEnrolled: true,
                isCollected: true
            ),
            "3": Activity(
                id: "3",
                title: "篮球社团招新活动",
                content: "篮球社团正在招新！无论你是篮球高手还是初学者，只要热爱篮球，都欢迎加入我们。\n\n活动内容：\n- 社团介绍\n- 篮球技巧展示\n- 友谊赛\n- 新成员报名\n\n让我们一起在球场上挥洒汗水！",
                coverUrl: "https://example.com/images/basketball.jpg",
                activityType: .club,
                location: "体育馆",
                organizer: "篮球社团",
                startTime: Date(timeIntervalSinceNow: 86400 * 5),
                endTime: Date(timeIntervalSinceNow: 86400 * 5 + 3600 * 2),
                quota: 50,
                currentEnrollments: 35,
                needSignIn: true,
                status: .published,
                createdAt: Date(timeIntervalSinceNow: -86400 * 7),
                isEnrolled: false,
                isCollected: false
            ),
            "4": Activity(
                id: "4",
                title: "编程竞赛：算法挑战赛",
                content: "一年一度的算法挑战赛开始报名！本次竞赛面向全校学生，旨在提高大家的编程能力和算法思维。\n\n竞赛规则：\n- 个人赛，限时3小时\n- 题目涵盖数据结构、算法设计等\n- 排名前10%将获得奖励\n- 优秀选手有机会参加省级竞赛\n\n报名截止时间：活动开始前1天",
                coverUrl: "https://example.com/images/coding_contest.jpg",
                activityType: .competition,
                location: "计算机实验室",
                organizer: "计算机学院",
                startTime: Date(timeIntervalSinceNow: 86400 * 10),
                endTime: Date(timeIntervalSinceNow: 86400 * 10 + 3600 * 3),
                quota: 100,
                currentEnrollments: 95,
                needSignIn: true,
                status: .published,
                createdAt: Date(timeIntervalSinceNow: -86400 * 15),
                isEnrolled: false,
                isCollected: true
            ),
            "5": Activity(
                id: "5",
                title: "环保主题讲座",
                content: "环保主题讲座将邀请环保专家为大家讲解：\n- 气候变化与环境保护\n- 可持续发展理念\n- 个人如何参与环保行动\n- 校园环保实践案例\n\n让我们一起为地球的可持续发展贡献力量！",
                coverUrl: "https://example.com/images/environment.jpg",
                activityType: .lecture,
                location: "教学楼A101",
                organizer: "环境科学学院",
                startTime: Date(timeIntervalSinceNow: 86400 * 2),
                endTime: Date(timeIntervalSinceNow: 86400 * 2 + 3600 * 1.5),
                quota: 150,
                currentEnrollments: 120,
                needSignIn: false,
                status: .published,
                createdAt: Date(timeIntervalSinceNow: -86400 * 3),
                isEnrolled: false,
                isCollected: false
            )
        ]
        
        return details[id]
    }
    
    /// Mock 分页信息
    static func getPagination(page: Int, pageSize: Int, total: Int) -> Pagination {
        let pages = (total + pageSize - 1) / pageSize // 向上取整
        return Pagination(
            total: total,
            page: page,
            pageSize: pageSize,
            pages: max(pages, 1) // 至少1页
        )
    }
    
    /// Mock 我的报名活动
    static var myEnrollments: [EnrollmentResponse] = [
        EnrollmentResponse(
            activityId: "2",
            title: "学术讲座：人工智能前沿技术",
            coverUrl: "https://example.com/images/ai_lecture.jpg",
            startTime: Date(timeIntervalSinceNow: 86400 * 3),
            endTime: Date(timeIntervalSinceNow: 86400 * 3 + 3600 * 2),
            myStatus: .enrolled
        )
    ]
    
    /// Mock 我的收藏活动
    static var myCollections: [CollectionResponse] = [
        CollectionResponse(
            activityId: "2",
            title: "学术讲座：人工智能前沿技术",
            coverUrl: "https://example.com/images/ai_lecture.jpg",
            startTime: Date(timeIntervalSinceNow: 86400 * 3),
            endTime: Date(timeIntervalSinceNow: 86400 * 3 + 3600 * 2)
        ),
        CollectionResponse(
            activityId: "4",
            title: "编程竞赛：算法挑战赛",
            coverUrl: "https://example.com/images/coding_contest.jpg",
            startTime: Date(timeIntervalSinceNow: 86400 * 10),
            endTime: Date(timeIntervalSinceNow: 86400 * 10 + 3600 * 3)
        )
    ]
}

