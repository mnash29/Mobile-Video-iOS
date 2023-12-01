//
//  ExploreHashtagViewModel.swift
//  TikTok
//
//  Created by mnash29 on 10/27/23.
//

import Foundation
import UIKit

struct ExploreHashtagViewModel {
    let icon: UIImage?
    let text: String
    let count: Int
    let handler: (() -> Void)
}
