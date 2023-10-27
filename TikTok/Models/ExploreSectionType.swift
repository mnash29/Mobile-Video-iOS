//
//  ExploreSectionType.swift
//  TikTok
//
//  Created by 206568245 on 10/27/23.
//

import Foundation

enum ExploreSectionType: CaseIterable {
    case users
    case banners
    case trendingPosts
    case trendingHashtags
    case recommended
    case popular
    case new

    var title: String {
        switch self {

        case .users:
            return "Popular Creators"
        case .banners:
            return "Featured"
        case .trendingPosts:
            return "Trending Videos"
        case .trendingHashtags:
            return "Hashtags"
        case .recommended:
            return "Recommended"
        case .popular:
            return "Popular"
        case .new:
            return "Recently Posted"
        }
    }
}
