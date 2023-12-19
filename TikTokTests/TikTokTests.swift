//
//  TikTokTests.swift
//  TikTokTests
//
//  Created by mnash29 on 12/19/23.
//

import XCTest

@testable import TikTok

final class TikTokTests: XCTestCase {

    func testPostChildPath() {
        let id = UUID().uuidString
        let user = User(username: "billgates", profilePictureURL: nil, identifier: "123test")
        var post = PostModel(identifier: id, user: user)

        XCTAssertTrue(post.caption.isEmpty)
        post.caption = "hello"
        XCTAssertFalse(post.caption.isEmpty)

        XCTAssertEqual(post.videoChildPath, "videos/\(user.username.lowercased())/")
        XCTAssertEqual(post.caption, "hello")

    }
}
