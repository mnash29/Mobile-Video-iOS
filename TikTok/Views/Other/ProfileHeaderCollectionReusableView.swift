//
//  ProfileHeaderCollectionReusableView.swift
//  TikTok
//
//  Created by mnash29 on 12/8/23.
//

import UIKit

protocol ProfileHeaderCollectionReusableViewDelegate: AnyObject {
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView,
                                             didTapPrimaryButtonWith: String)
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView,
                                             didTapFollowersButtonWith: String)
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView,
                                             didTapFollowingButtonWith: String)
}

class ProfileHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "ProfileHeaderCollectionReusableView"

    weak var delegate: ProfileHeaderCollectionReusableViewDelegate?

    var viewModel: ProfileHeaderViewModel?

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .secondarySystemBackground

        return imageView
    }()

    private let primaryButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true

        return button
    }()

    private let followersButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        button.setTitle("Followers", for: .normal)

        return button
    }()

    private let followingButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        button.setTitle("Followings", for: .normal)
        return button
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = .systemBackground
        addSubviews()
        configureButtons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    func addSubviews() {
        addSubview(avatarImageView)
        addSubview(primaryButton)
        addSubview(followersButton)
        addSubview(followingButton)
    }

    func configureButtons() {
        primaryButton.addTarget(self, action: #selector(didTapPrimaryButton), for: .touchUpInside)
        followersButton.addTarget(self, action: #selector(didTapFollowersButton), for: .touchUpInside)
        followingButton.addTarget(self, action: #selector(didTapFollowingButton), for: .touchUpInside)
    }

    @objc func didTapPrimaryButton() {
        delegate?.profileHeaderCollectionReusableView(self,
                                                      didTapPrimaryButtonWith: "")
    }

    @objc func didTapFollowersButton() {
        delegate?.profileHeaderCollectionReusableView(self,
                                                      didTapFollowersButtonWith: "")

    }

    @objc func didTapFollowingButton() {
        delegate?.profileHeaderCollectionReusableView(self,
                                                      didTapFollowingButtonWith: "")
    }

    func configure(with viewModel: ProfileHeaderViewModel) {
        self.viewModel = viewModel
    }
}
