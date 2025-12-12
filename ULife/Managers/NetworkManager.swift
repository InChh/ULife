//
//  NetworkManager.swift
//  ULife
//
//  Created by 刘宏伟 on 2025/12/1.
//

import Foundation
import UlifeLib

enum NetworkManager {
    static let client: ApiClient = {
        do {
            return try ApiClient(
                baseUrl: "http://localhost:8888",
                cacheFolder: getCachesDirectory().absoluteString,
                cacheSize: 1024 * 100,
                fs: SwiftFileSystem()
            )
        } catch {
            fatalError("Failed to initialize ApiClient: \(error)")
        }
    }()
}
