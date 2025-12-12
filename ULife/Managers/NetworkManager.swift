//
//  NetworkManager.swift
//  ULife
//
//  Created by 刘宏伟 on 2025/12/1.
//

import Foundation
import UlifeLib

enum NetworkManager {
    static let courseClient: ApiClient = {
        do {
            return try ApiClient.withProtocol(
                baseUrl: "https://m1.apifoxmock.com/m1/7500709-7236287-default/api/v1/",
                protocol: .json
            )
        } catch {
            fatalError("Failed to initialize ApiClient: \(error)")
        }
    }()
    
    static let userClient: ApiClient = {
        do {
            return try ApiClient.withProtocol(
                baseUrl: "https://m1.apifoxmock.com/m1/7500709-7236287-6678144/api/v1/",
                protocol: .json
            )
        } catch {
            fatalError("Failed to initialize User ApiClient: \(error)")
        }
    }()
    
    static let activityClient: ApiClient = {
        do {
            return try ApiClient.withProtocol(
                baseUrl: "https://m1.apifoxmock.com/m1/7500709-7236287-6678142/api/v1/",
                protocol: .json
            )
        } catch {
            fatalError("Failed to initialize User ApiClient: \(error)")
        }
    }()
    
    static let forumClient: ApiClient = {
        do {
            return try ApiClient.withProtocol(
                baseUrl: "https://m1.apifoxmock.com/m1/7500709-7236287-6678143/api/v1/",
                protocol: .json
            )
        } catch {
            fatalError("Failed to initialize User ApiClient: \(error)")
        }
    }()
}
