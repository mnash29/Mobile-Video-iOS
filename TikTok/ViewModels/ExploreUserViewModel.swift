//
//  ExploreUserViewModel.swift
//  TikTok
//
//  Created by mnash29 on 10/27/23.
//

import Foundation
import UIKit

struct ExploreUserViewModel {
    let profilePicture: UIImage?
    let username: String
    let followerCount: Int
    let handler: (() -> Void)
}
