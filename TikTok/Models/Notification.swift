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
        return Array(0...100).compactMap { number in
            Notification(
                text: "Something happened: \(number)",
                type: .userFollow(username: "charlidamelio"),
                date: Date())
        }
    }
}
