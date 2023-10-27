//
//  ExploreCell.swift
//  TikTok
//
//  Created by 206568245 on 10/27/23.
//

import Foundation

enum ExploreCell {
    case banner(viewModel: ExploreBannerViewModel)
    case post(viewModel: ExplorePostViewModel)
    case hashtag(viewModel: ExploreHashtagViewModel)
    case user(viewModel: ExploreUserViewModel)
}
