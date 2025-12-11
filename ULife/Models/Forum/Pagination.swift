//
//  Pagination.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/8.
//


import Foundation

/// Pagination
// MARK: - Pagination
public struct Pagination: Codable, Equatable {
    /// 当前页码
    public var page: Int
    /// 总页数
    public var pages: Int
    /// 每页限制数
    public var pageSize: Int
    /// 总记录数
    public var total: Int

    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case pageSize = "page_size"
        case total
    }

    public init(page: Int, pages: Int, pageSize: Int, total: Int) {
        self.page = page
        self.pages = pages
        self.pageSize = pageSize
        self.total = total
    }
}
