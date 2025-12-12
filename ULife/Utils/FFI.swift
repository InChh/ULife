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
        let url = URL(fileURLWithPath: path)
        try await Task {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }.value
    }
    
    func fileExists(path: String) async throws -> Bool {
        let url = URL(fileURLWithPath: path)
        return await Task {
            return FileManager.default.fileExists(atPath: url.path)
        }.value
    }
    
    func write(path: String, data: Data) async throws {
        let url = URL(fileURLWithPath: path)
        try await Task {
            try data.write(to: url, options: .atomic)
        }.value
    }
    
    func read(path: String) async throws -> Data {
        let url = URL(fileURLWithPath: path)
        return try await Task {
            try Data(contentsOf: url)
        }.value
    }
    
    func removeFile(path: String) async throws {
        let url = URL(fileURLWithPath: path)
        try await Task {
            try FileManager.default.removeItem(at: url)
        }.value
    }
    
    func rename(from: String, to: String) async throws {
        let fromUrl = URL(fileURLWithPath: from)
        let toUrl = URL(fileURLWithPath: to)
        try await Task {
            try FileManager.default.moveItem(at: fromUrl, to: toUrl)
        }.value
    }
    
    func removeDirAll(path: String) async throws {
        let url = URL(fileURLWithPath: path)
        try await Task {
            try FileManager.default.removeItem(at: url)
        }.value
    }
    
    func readBlocking(path: String) throws -> Data {
        let url = URL(fileURLWithPath: path)
        if !FileManager.default.fileExists(atPath: path) {
            throw Error.FileNotFound(message: "File not found at path: \(path)")
        }
        return try Data(contentsOf: url)
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
