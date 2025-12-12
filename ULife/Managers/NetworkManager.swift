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
            return try ApiClient.withProtocol(
                baseUrl: "https://m1.apifoxmock.com/m1/7500709-7236287-6678144",
                protocol: .json
            )
        } catch {
            fatalError("Failed to initialize ApiClient: \(error)")
        }
    }()
}
