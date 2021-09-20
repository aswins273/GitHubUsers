//
//  UsersModel.swift
//  GitHub-Users
//
//  Created by S, Aswin on 17/09/21.
//

import Foundation

struct GithubUsers : Codable {        //
    let items: [User]
}

struct User : Codable {
    let login: String?
    let avatarUrl: String?
    let htmlUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case login = "login"
        case avatarUrl = "avatar_url"
        case htmlUrl = "html_url"
    }
}
