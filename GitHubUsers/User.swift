//
//  User.swift
//  GitHubUsers
//
//  Created by Radosław Serek on 10.05.2018.
//  Copyright © 2018 Radosław Serek. All rights reserved.
//

import Foundation

struct User: Codable {
    
    let avatarUrl: String
    let htmlUrl: String
    let id: Int
    let login: String
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case avatarUrl = "avatar_url"
        case htmlUrl = "html_url"
        case id
        case login
        case type
    }
    
}


