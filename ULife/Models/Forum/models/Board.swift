// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let board = try Board(json)

import Foundation

/// Board，论坛板块的详细信息模型，通常通过 GET /boards/{id} 获取。
// MARK: - Board
public struct Board: Equatable {
    /// 板块的简短描述或标语。
    public var description: String?
    /// 板块图标，使用 Unicode 字符或 Emoji。
    public var icon: String?
    /// 板块的唯一标识符。
    public var id: String?
    /// 板块名称，例如：二手交易。
    public var name: String?
    /// 板块类型。static: 预设板块；dynamic: 管理员临时创建的板块。
    public var type: TypeEnum?

    public init(description: String?, icon: String?, id: String?, name: String?, type: TypeEnum?) {
        self.description = description
        self.icon = icon
        self.id = id
        self.name = name
        self.type = type
    }
}

/// 板块类型。static: 预设板块；dynamic: 管理员临时创建的板块。
public enum TypeEnum: String, Equatable {
    case typeDynamic
    case typeStatic
}