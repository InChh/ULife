//
//  ActivityModels.swift
//  ULife
//
//  Created for mock Activity module
//

import Foundation
import UlifeLib

extension ActivityType {
    var displayName: String {
        switch self {
            case .lecture: return "讲座"
            case .club: return "社团"
            case .competition: return "竞赛"
            case .unknown: return "未知"
        }
    }
}
