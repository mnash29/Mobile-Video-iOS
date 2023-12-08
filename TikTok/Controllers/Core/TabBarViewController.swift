//
//  TabBarViewController.swift
//  TikTok
//
//  Created by mnash29 on 10/9/23.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpControllers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !AuthManager.shared.isSignedIn {
            presentSignInIfNeeded()
        }
    }

    private func presentSignInIfNeeded() {
        let vc = SignInViewController()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen

        present(navVC, animated: false, completion: nil)
    }

    private func setUpControllers() {
        let home = HomeViewController()
        let explore = ExploreViewController()
        let camera = CameraViewController()
        let notifications = NotificationViewController()
        let profile = ProfileViewController(
            user: User(
                username: UserDefaults.standard.string(forKey: "username")?.uppercased() ?? "Me",
                profilePictureURL: nil,
                identifier: UserDefaults.standard.string(forKey: "username")?.lowercased() ?? ""
            )
        )

        notifications.title = "Notifications"
        profile.title = "Profile"

        let nav1 = UINavigationController(rootViewController: home)
        let nav2 = UINavigationController(rootViewController: explore)
        let cameraNav = UINavigationController(rootViewController: camera)
        let nav3 = UINavigationController(rootViewController: notifications)
        let nav4 = UINavigationController(rootViewController: profile)

        nav1.navigationBar.backgroundColor = .clear
        nav1.navigationBar.setBackgroundImage(UIImage(), for: .default)
        nav1.navigationBar.shadowImage = UIImage()

        cameraNav.navigationBar.backgroundColor = .clear
        cameraNav.navigationBar.setBackgroundImage(UIImage(), for: .default)
        cameraNav.navigationBar.shadowImage = UIImage()
        cameraNav.navigationBar.tintColor = .white

        nav3.navigationBar.tintColor = .label

        // Assign a tab bar item to each view controller
        nav1.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "binoculars"), tag: 2)
        cameraNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "camera"), tag: 3)
        nav3.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "bell"), tag: 4)
        nav4.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "person.circle"), tag: 5)

        if #available(iOS 14.0, *) {
            nav1.navigationItem.backButtonDisplayMode = .minimal
            nav2.navigationItem.backButtonDisplayMode = .minimal
            cameraNav.navigationItem.backButtonDisplayMode = .minimal
            nav3.navigationItem.backButtonDisplayMode = .minimal
            nav4.navigationItem.backButtonDisplayMode = .minimal
        }

        setViewControllers([nav1, nav2, cameraNav, nav3, nav4], animated: false)
        
    }
}
