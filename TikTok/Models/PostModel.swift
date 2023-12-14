//
//  PostModel.swift
//  TikTok
//
//  Created by mnash29 on 10/11/23.
//

import Foundation

struct PostModel {
    let identifier: String
    let user: User
    var fileName: String = ""
    var caption: String = ""
    var isLikedByCurrentUser = false

    var videoChildPath: String {
        return "videos/\(user.username.lowercased())/\(fileName)"
    }

    static func mockModels() -> [PostModel] {
        let posts = Array(0...100).compactMap({ _ in
            PostModel(
                identifier: UUID().uuidString,
                user: User(
                    username: "kanyewest",
                    profilePictureURL: nil,
                    identifier: UUID().uuidString
                )
            )
        })

        return posts
    }
}
