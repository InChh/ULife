//
//  ForumRequest.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/9.
//
import UIKit
import UlifeLib


public enum Filter: String, Equatable {
    case all
    case myCollege
}

public enum Sort: String, Equatable {
    case hot
    case latest
    case new
}
