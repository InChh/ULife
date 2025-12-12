//
//  FileSystem.swift
//  ULife
//
//  Created by 刘宏伟 on 2025/12/11.
//

import Foundation
import UlifeLib

final class SwiftFileSystem: FileSystem {
    func createDirAll(path: String) async throws {
        // 递归创建目录
        let fileManager = FileManager.default
        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    }
    
    func write(path: String, data: Data) async throws {
        let fileManager = FileManager.default
        try fileManager.createFile(atPath: path, contents: data, attributes: nil)
    }
    
    func read(path: String) async throws -> Data {
        let fileManager = FileManager.default
        return try Data(contentsOf: URL(fileURLWithPath: path))
    }
    
    func removeFile(path: String) async throws {
        let fileManager = FileManager.default
        try fileManager.removeItem(atPath: path)
    }
    
    func rename(from: String, to: String) async throws {
        let fileManager = FileManager.default
        try fileManager.moveItem(atPath: from, toPath: to)
    }
    
    func removeDirAll(path: String) async throws {
        let fileManager = FileManager.default
        try fileManager.removeItem(atPath: path)
    }
    
    func readBlocking(path: String) throws -> Data {
        let fileManager = FileManager.default
        return try Data(contentsOf: URL(fileURLWithPath: path))
    }
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

func getCachesDirectory() -> URL {
    let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
    return paths[0]
}
