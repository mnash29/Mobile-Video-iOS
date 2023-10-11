//
//  PostModel.swift
//  TikTok
//
//  Created by 206568245 on 10/11/23.
//

import Foundation

struct PostModel {
    let identifier: String

    static func mockModels() -> [PostModel] {
        let posts = Array(0...100).compactMap({_ in
            PostModel(identifier: UUID().uuidString)
        })

        return posts
    }
}
