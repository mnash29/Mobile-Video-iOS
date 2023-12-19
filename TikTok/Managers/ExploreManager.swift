//
//  ExploreManager.swift
//  TikTok
//
//  Created by mnash29 on 11/3/23.
//

import Foundation
import UIKit

/// Delegate interface to notify manager of events
protocol ExploreManagerDelegate: AnyObject {

    /// Notify a view controller should be pushed
    /// - Parameter vc: The view controller to present
    func pushViewController(_ vc: UIViewController)

    /// Notify a hashtag element was tapped
    /// - Parameter hashtag: The hashtag that was tapped
    func didTapHashtag(_ hashtag: String)
}

/// Manager for the `ExploreViewController` operations and events
final class ExploreManager {

    /// Shared singleton instance of the `ExploreManager`
    static let shared = ExploreManager()

    /// Delegate to notify of event
    weak var delegate: ExploreManagerDelegate?

    /// Represents banner action types
    enum BannerAction: String {
        case post
        case hashtag
        case user
    }

    // MARK: - Public

    /// Get explore data for banners
    /// - Returns: Return an optional collection of `ExploreBannerViewModel`
    public func getExploreBanners() -> [ExploreBannerViewModel] {
        guard let exploreData = parseExploreData() else {
            return []
        }

        return exploreData.banners.compactMap({ model in
            ExploreBannerViewModel(
                image: UIImage(named: model.image),
                title: model.title
            ) { [weak self] in
                guard let action = BannerAction(rawValue: model.action) else {
                    return
                }

                DispatchQueue.main.async {
                    let vc = UIViewController()
                    vc.view.backgroundColor = .systemBackground
                    vc.title = action.rawValue.uppercased()
                    self?.delegate?.pushViewController(vc)
                }

                switch action {
                case .user:
                    break
                case .post:
                    break
                case .hashtag:
                    break
                }
            }
        })
    }

    /// Get explore data for recommended users
    /// - Returns: Return an optional collection of `ExploreUserViewModel`
    public func getExploreCreators() -> [ExploreUserViewModel] {
        guard let exploreData = parseExploreData() else {
            return []
        }

        return exploreData.creators.compactMap({ model in
            ExploreUserViewModel(
                profilePicture: UIImage(named: model.image),
                username: model.username,
                followerCount: model.followers_count
            ) { [weak self] in

                DispatchQueue.main.async {
                    let userId = model.id
                    // Fetch user object from firebase
                    let vc = ProfileViewController(
                        user: User(
                            username: "joe",
                            profilePictureURL: nil,
                            identifier: userId
                        )
                    )
                    self?.delegate?.pushViewController(vc)
                }
            }
        })
    }

    /// Get explore data for hashtags
    /// - Returns: Return an optional collection of `ExploreHashtagViewModel`
    public func getExploreHashtags() -> [ExploreHashtagViewModel] {
        guard let exploreData = parseExploreData() else {
            return []
        }

        return exploreData.hashtags.compactMap({ model in
            ExploreHashtagViewModel(
                icon: UIImage(named: model.image),
                text: model.tag,
                count: model.count
            ) { [weak self] in
                DispatchQueue.main.async {
                    self?.delegate?.didTapHashtag(model.tag)
                }
            }
        })
    }

    /// Get explore data for trending posts
    /// - Returns: Return an optional collection of `ExplorePostViewModel`
    public func getExploreTrendingPosts() -> [ExplorePostViewModel] {
        guard let exploreData = parseExploreData() else {
            return []
        }

        return exploreData.trendingPosts.compactMap({ model in
            ExplorePostViewModel(
                thumbailImage: UIImage(named: model.image),
                caption: model.caption
            ) { [weak self] in
                DispatchQueue.main.async {
                    let vc = PostViewController(model: PostModel(
                        identifier: model.id,
                        user: User(
                            username: "kanyewest",
                            profilePictureURL: nil,
                            identifier: UUID().uuidString
                        )
                    ))
                    vc.delegate = self
                    self?.delegate?.pushViewController(vc)
                }
            }
        })
    }

    /// Get explore data for recent posts
    /// - Returns: Return an optional collection of `ExplorePostViewModel`
    public func getExploreRecentPosts() -> [ExplorePostViewModel] {
        guard let exploreData = parseExploreData() else {
            return []
        }

        return exploreData.recentPosts.compactMap({ model in
            ExplorePostViewModel(
                thumbailImage: UIImage(named: model.image),
                caption: model.caption
            ) {[weak self] in
                DispatchQueue.main.async {
                    let vc = PostViewController(model: PostModel(
                        identifier: model.id,
                        user: User(
                            username: "kanyewest",
                            profilePictureURL: nil,
                            identifier: UUID().uuidString
                        )
                    ))
                    vc.delegate = self
                    self?.delegate?.pushViewController(vc)
                }
            }
        })
    }

    /// Get explore data for popular posts
    /// - Returns: Return an optional collection of `ExplorePostViewModel`
    public func getExplorePopularPosts() -> [ExplorePostViewModel] {
        guard let exploreData = parseExploreData() else {
            return []
        }

        return exploreData.popular.compactMap({ model in
            ExplorePostViewModel(
                thumbailImage: UIImage(named: model.image),
                caption: model.caption
            ) {[weak self] in
                DispatchQueue.main.async {
                    let vc = PostViewController(model: PostModel(
                        identifier: model.id,
                        user: User(
                            username: "kanyewest",
                            profilePictureURL: nil,
                            identifier: UUID().uuidString
                        )
                    ))
                    vc.delegate = self
                    self?.delegate?.pushViewController(vc)
                }
            }
        })
    }

    /// Get explore data for recommended posts
    /// - Returns: Return an optional collection of `ExplorePostViewModel`
    public func getExploreRecommendedPosts() -> [ExplorePostViewModel] {
        guard let exploreData = parseExploreData() else {
            return []
        }

        return exploreData.recommended.compactMap({ model in
            ExplorePostViewModel(
                thumbailImage: UIImage(named: model.image),
                caption: model.caption
            ) {[weak self] in
                DispatchQueue.main.async {
                    let vc = PostViewController(model: PostModel(
                        identifier: model.id,
                        user: User(
                            username: "kanyewest",
                            profilePictureURL: nil,
                            identifier: UUID().uuidString
                        )
                    ))
                    vc.delegate = self
                    self?.delegate?.pushViewController(vc)
                }
            }
        })
    }

    // MARK: - Private

    /// Parase explore JSON data
    /// - Returns: Returns an optional response model
    private func parseExploreData() -> ExploreResponse? {
        guard let path = Bundle.main.path(forResource: "explore", ofType: "json") else {
            return nil
        }

        do {
            let url = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(ExploreResponse.self, from: data)
        } catch {
            print(error)
            return nil
        }

    }
}

// MARK: - PostViewControllerDelegate methods

extension ExploreManager: PostViewControllerDelegate {
    func postViewController(_ vc: PostViewController, didTapCommentButtonFor post: PostModel) {
        print("ExploreManager.didTapCommentButtonFor not configured.")
    }

    func postViewController(_ vc: PostViewController, didTapProfileButtonFor post: PostModel) {
        let user = post.user
        let vc = ProfileViewController(user: user)

        delegate?.pushViewController(vc)
    }

}

struct ExploreResponse: Codable {
    let banners: [Banner]
    let trendingPosts: [Post]
    let creators: [Creator]
    let recentPosts: [Post]
    let hashtags: [Hashtag]
    let popular: [Post]
    let recommended: [Post]
}

struct Banner: Codable {
    let id: String
    let image: String
    let title: String
    let action: String
}

struct Post: Codable {
    let id: String
    let image: String
    let caption: String
}

struct Hashtag: Codable {
    let tag: String
    let image: String
    let count: Int
}

struct Creator: Codable {
    let id: String
    let image: String
    let username: String
    let followers_count: Int
}
