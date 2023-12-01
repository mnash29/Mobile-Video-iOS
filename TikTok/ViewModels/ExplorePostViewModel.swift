//
//  ExplorePostViewModel.swift
//  TikTok
//
//  Created by mnash29 on 10/27/23.
//

import Foundation
import UIKit

struct ExplorePostViewModel {
    let thumbailImage: UIImage?
    let caption: String
    let handler: (() -> Void)
}
