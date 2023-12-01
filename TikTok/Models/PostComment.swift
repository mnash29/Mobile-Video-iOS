//
//  PostComment.swift
//  TikTok
//
//  Created by mnash29 on 10/25/23.
//

import Foundation

struct PostComment {
    let text: String
    let user: User
    let date: Date

    static func mockComments() -> [PostComment] {
        let user = User(username: "kanyewest", profilePictureURL: nil, identifier: UUID().uuidString)

        var comments = [PostComment]()

        let text = [
            "This is a cool post!",
            "This is an awesome post!",
            "This is a pretty sweet project tutorial!"
        ]

        for comment in text {
            comments.append(
                PostComment(text: comment, user: user, date: Date())
            )
        }

        return comments
    }
}

