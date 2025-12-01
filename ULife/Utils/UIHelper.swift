//
//  UIHelper.swift
//  ULife
//
//  Created by 刘宏伟 on 2025/12/1.
//

import UIKit

enum UIHelper {
    static func createTabViewController() -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [createCalendarNavigationController(),
                                            createActivityNavigationController(),
                                            createForumNavigationController(),
                                            createProfileNavigationController()]
                                
        return tabBarController
    }
    
    static func createCalendarNavigationController() -> UINavigationController {
        let calendarViewController = CalendarViewController()
        let navigationController = UINavigationController(rootViewController: calendarViewController)
        navigationController.tabBarItem = UITabBarItem(title: NSLocalizedString("Calendar", comment: ""), image: UIImage(systemName: "calendar"), selectedImage: UIImage(systemName: "calendar.fill"))
        return navigationController
    }

    static func createActivityNavigationController() -> UINavigationController {
        let activityViewController = ActivityViewController()
        let navigationController = UINavigationController(rootViewController: activityViewController)
        navigationController.tabBarItem = UITabBarItem(title: NSLocalizedString("Activity", comment: ""), image: UIImage(systemName: "flame"), selectedImage: UIImage(systemName: "flame.fill"))
        return navigationController
    }
    
    static func createForumNavigationController() -> UINavigationController {
        let forumViewController = ForumViewController()
        let navigationController = UINavigationController(rootViewController: forumViewController)
        navigationController.tabBarItem = UITabBarItem(title: NSLocalizedString("Forum", comment: ""), image: UIImage(systemName: "text.bubble"), selectedImage: UIImage(systemName: "text.bubble.fill"))
        return navigationController
    }
    
    static func createProfileNavigationController() -> UINavigationController {
        let profileViewController = ProfileViewController()
        let navigationController = UINavigationController(rootViewController: profileViewController)
        navigationController.tabBarItem = UITabBarItem(title: NSLocalizedString("Profile", comment: ""), image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        return navigationController
    }
}
