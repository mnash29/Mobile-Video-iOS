//
//  Notifications.swift
//  TikTok
//
//  Created by mnash29 on 12/1/23.
//

import Foundation

enum NotificationType {
    case postLike(postName: String)
    case userFollow(username: String)
    case postComment(postName: String)

    var id: String {
        switch self {
        case .postLike: return "postLike"
        case .userFollow: return "userFollow"
        case .postComment: return "postComment"
        }
    }
}

struct Notification {
    let text: String
    let type: NotificationType
    let date: Date

    static func mockData() -> [Notification] {
        let first = Array(0...5).compactMap { number in
            Notification(
                text: "Something happened: \(number)",
                type: .userFollow(username: "bradstevens"),
                date: Date())
        }

        let second = Array(0...5).compactMap { number in
            Notification(
                text: "Something happened: \(number)",
                type: .postLike(postName: "Some random post name"),
                date: Date())
        }

        let third = Array(0...5).compactMap { number in
            Notification(
                text: "Something happened: \(number)",
                type: .postComment(postName: "Some random post name"),
                date: Date())
        }

        return first + second + third
    }
}
