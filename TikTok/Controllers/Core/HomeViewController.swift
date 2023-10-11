//
//  ViewController.swift
//  TikTok
//
//  Created by mnash29 on 10/6/23.
//

import UIKit

class HomeViewController: UIViewController {

    private let horizontalScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.backgroundColor = .red
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false

        return scrollView
    }()

    private let forYouPostModels = PostModel.mockModels()
    private let followingPostModels = PostModel.mockModels()

    private let forYouPagingController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .vertical,
        options: [:]
    )

    private let followingPagingController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .vertical,
        options: [:]
    )

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(horizontalScrollView)
        setUpFeeds()
        horizontalScrollView.contentOffset = CGPoint(x: view.width, y: 0)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        horizontalScrollView.frame = view.bounds
    }

    private func setUpFeeds() {
        horizontalScrollView.contentSize = CGSize(width: view.width * 2, height: view.height)

        setUpFollowingFeed()
        setUpForYouFeed()
    }

    private func setUpFollowingFeed() {
        guard let model = followingPostModels.first else {
            return
        }

        followingPagingController.setViewControllers(
            [PostViewController(model: model)],
            direction: .forward,
            animated: false,
            completion: nil
        )

        // As user swipes up/down the `pagingController` behaves a lot like a `TableViewController`
        // that needs to load the data for the next controller so it requires a `dataSource`
        followingPagingController.dataSource = self

        horizontalScrollView.addSubview(followingPagingController.view)
        followingPagingController.view.frame = CGRect(x: 0,
                                             y: 0,
                                             width: horizontalScrollView.width,
                                             height: horizontalScrollView.height)
        addChild(followingPagingController)
        followingPagingController.didMove(toParent: self)
    }

    private func setUpForYouFeed() {
        guard let model = forYouPostModels.first else {
            return
        }

        forYouPagingController.setViewControllers(
            [PostViewController(model: model)],
            direction: .forward,
            animated: false,
            completion: nil
        )

        // As user swipes up/down the `pagingController` behaves a lot like a `TableViewController`
        // that needs to load the data for the next controller so it requires a `dataSource`
        forYouPagingController.dataSource = self

        horizontalScrollView.addSubview(forYouPagingController.view)
        forYouPagingController.view.frame = CGRect(x: view.width,
                                             y: 0,
                                             width: horizontalScrollView.width,
                                             height: horizontalScrollView.height)
        addChild(forYouPagingController)
        forYouPagingController.didMove(toParent: self)
    }

}

// MARK: - HomeViewController DataSource

extension HomeViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let fromPost = (viewController as? PostViewController)?.model else {
            return nil
        }

        guard let index = currentPosts.firstIndex(where: {
            $0.identifier == fromPost.identifier
        }) else {
            return nil
        }

        if index == 0 {
            return nil
        }

        let priorIndex = index - 1
        let model = currentPosts[priorIndex]
        let vc = PostViewController(model: model)
        return vc
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let fromPost = (viewController as? PostViewController)?.model else {
            return nil
        }

        guard let index = currentPosts.firstIndex(where: {
            $0.identifier == fromPost.identifier
        }) else {
            return nil
        }

        guard index < (currentPosts.count - 1) else {
            return nil
        }

        let nextIndex = index + 1
        let model = currentPosts[nextIndex]
        let vc = PostViewController(model: model)
        return vc
    }

    private var currentPosts: [PostModel] {
        if horizontalScrollView.contentOffset.x == 0 {
            // in Following page
            return followingPostModels
        }

        // in For You page
        return forYouPostModels
    }

}
