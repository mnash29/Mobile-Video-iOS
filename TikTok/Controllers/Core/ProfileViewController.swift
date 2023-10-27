//
//  ProfileViewController.swift
//  TikTok
//
//  Created by mnash29 on 10/9/23.
//

import UIKit

class ProfileViewController: UIViewController {

    let user: User

    // MARK: - Init

    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = user.username.uppercased()
        view.backgroundColor = .systemBackground
        
    }

}
