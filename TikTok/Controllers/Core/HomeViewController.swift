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
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false

        return scrollView
    }()

    private let control: UISegmentedControl = {
        let titles = ["Following", "For You"]
        let control = UISegmentedControl(items: titles)
        control.selectedSegmentIndex = 1
        control.backgroundColor = nil
        control.selectedSegmentTintColor = .white
        control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)

        return control
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

        // Fix inset adjustment issue when opening app
        horizontalScrollView.contentInsetAdjustmentBehavior = .never

        horizontalScrollView.delegate = self
        horizontalScrollView.contentOffset = CGPoint(x: view.width, y: 0)
        setUpHeaderButtons()

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        horizontalScrollView.frame = view.bounds
    }

    private func setUpHeaderButtons() {
        control.addTarget(self, action: #selector(didChangeSegmentControl(_:)), for: .valueChanged)
        navigationItem.titleView = control
    }

    @objc private func didChangeSegmentControl(_ sender: UISegmentedControl) {
        horizontalScrollView.setContentOffset(
            CGPoint(
                x: view.width * CGFloat(sender.selectedSegmentIndex),
                y: 0
            ),
            animated: true
        )
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

        let vc = PostViewController(model: model)
        vc.delegate = self

        followingPagingController.setViewControllers(
            [vc],
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

        let vc = PostViewController(model: model)
        vc.delegate = self

        forYouPagingController.setViewControllers(
            [vc],
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
        vc.delegate = self
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
        vc.delegate = self
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

// MARK: - UIScrollView delegate methods

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == 0 || scrollView.contentOffset.x <= (view.width/2) {
            control.selectedSegmentIndex = 0
        } else if scrollView.contentOffset.x > (view.width/2) {
            control.selectedSegmentIndex = 1
        }
    }
}

// MARK: - PostViewController delegate methods

extension HomeViewController: PostViewControllerDelegate {
    func postViewController(_ vc: PostViewController, didTapProfileButtonFor post: PostModel) {
        let user = post.user
        let vc = ProfileViewController(user: user)

        navigationController?.pushViewController(vc, animated: true)
    }

    func postViewController(_ vc: PostViewController, didTapCommentButtonFor post: PostModel) {
        horizontalScrollView.isScrollEnabled = false

        if horizontalScrollView.contentOffset.x == 0 {
            // Following feed
            followingPagingController.dataSource = nil
        } else {
            // For You feed
            forYouPagingController.dataSource = nil
        }

        HapticsManager.shared.vibrateForSeletion()

        let vc = CommentViewController(post: post)
        vc.delegate = self

        addChild(vc)
        vc.didMove(toParent: self)
        view.addSubview(vc.view)
        let frame: CGRect = CGRect(x: 0, y: view.height, width: view.width, height: view.height * 0.76)

        vc.view.frame = frame
        UIView.animate(withDuration: 0.2) {
            vc.view.frame = CGRect(x: 0, y: self.view.height - frame.height, width: frame.width, height: frame.height)
        }
    }
}

// MARK: - CommentsViewController delegate methods

extension HomeViewController: CommentsViewControllerDelegate {
    func didTapCloseForComments(with viewController: CommentViewController) {
        // Animate closure of comments, Allow horizontal and vertical scrolling, Remove comment vc as child

        let frame = viewController.view.frame

        UIView.animate(withDuration: 0.2) {
            viewController.view.frame = CGRect(x: 0, y: self.view.height, width: frame.width, height: frame.height)
        } completion: { [weak self] done in
            if done {
                DispatchQueue.main.async {
                    viewController.view.removeFromSuperview()
                    viewController.removeFromParent()
                    self?.horizontalScrollView.isScrollEnabled = true
                    self?.forYouPagingController.dataSource = self
                    self?.followingPagingController.dataSource = self
                }
            }
        }
    }

}
