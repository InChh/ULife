import Foundation

/// Pagination
// MARK: - Pagination
public struct Pagination: Equatable {
    /// 当前页码
    public var page: Int
    /// 总页数
    public var pages: Int
    /// 每页限制数
    public var pageSize: Int
    /// 总记录数
    public var total: Int

    public init(page: Int, pages: Int, pageSize: Int, total: Int) {
        self.page = page
        self.pages = pages
        self.pageSize = pageSize
        self.total = total
    }
}
