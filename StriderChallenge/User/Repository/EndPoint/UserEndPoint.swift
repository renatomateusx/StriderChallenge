//
//  UserEndPoint.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 29/08/22.
//

import Foundation

struct UserEndPoint {
    let appConfiguration: AppConfigurations

    var host: String {
        return appConfiguration.apiBaseURL
    }
    
    var appId: String {
        return appConfiguration.apiKey
    }

    var path: String {
        return ""
    }
    
    var url: URL {
        return URL(string: "\(host)\(path)")!
    }

    var headers: [String: String] {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}
