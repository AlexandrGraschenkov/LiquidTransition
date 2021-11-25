//
//  GithubUser.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 04/10/2019.
//  Copyright © 2019 Alex Development. All rights reserved.
//

import UIKit

struct GUser: Decodable {
    let id: Int64
    let login: String
    let avatar: URL?
}

struct GUserFull: Decodable {
    let id: Int64
    let login: String
    let avatar: URL?
    
    let name: String?
    let bio: String?
    let company: String?
    let publicRepos: Int
    let publicGists: Int
    let followers: Int
    let following: Int
    let location: String?
    
    
    
    enum CodingKeys: String, CodingKey {
        case id, login, avatar
        case name, bio, company, followers, following, location
        
        case publicRepos = "public_repos"
        case publicGists = "public_gists"
    }
}
