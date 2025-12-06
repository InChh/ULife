//
//  CreatePostRequest.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/5.
//


import Foundation

struct CreatePostRequest {
    var title: String = ""
    var content: String = ""
    
    var tags: [String] = []
    
    // 检查发帖数据是否有效（业务校验）
    var isValid: Bool {
        return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
}
