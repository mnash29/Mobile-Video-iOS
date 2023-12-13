//
//  ProfileViewController.swift
//  TikTok
//
//  Created by mnash29 on 10/9/23.
//

import UIKit
import ProgressHUD

class ProfileViewController: UIViewController {

    var user: User

    var isCurrentUserProfile: Bool {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return false
        }

        return user.username.lowercased() == username.lowercased()
    }

    private var posts = [PostModel]()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .systemBackground
        collection.showsVerticalScrollIndicator = false
        collection.register(
            ProfileHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier
        )
        collection.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: "cell"
        )
        return collection
    }()

    // MARK: - Init

    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = user.username.uppercased()
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self

        if AuthManager.shared.isSignedIn {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "gearshape.fill"),
                style: .done,
                target: self,
                action: #selector(didTapSettings)
            )
        }

        fetchPosts()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    @objc func didTapSettings() {
        let vc = SettingsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func fetchPosts() {
        DatabaseManager.shared.getPosts(for: user) { [weak self] postModels in
            DispatchQueue.main.async {
                self?.posts = postModels
                self?.collectionView.reloadData()
            }
        }
    }

}

// MARK: - UICollectionViewDelegate methods
extension ProfileViewController: UICollectionViewDelegate {

}

// MARK: - UICollectionViewDataSource methods

extension ProfileViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let postModel = posts[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .systemBlue

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // Open post
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = (view.width - 12) / 3
        return CGSize(width: width, height: width * 1.5)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier,
                for: indexPath
              ) as? ProfileHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }

        header.delegate = self
        let viewModel = ProfileHeaderViewModel(
            avatarImageURL: user.profilePictureURL,
            followerCount: 120,
            followingCount: 200,
            isFollowing: isCurrentUserProfile ? nil : false
        )
        header.configure(with: viewModel)

        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.width, height: 300)
    }
}

// MARK: - UICollectionViewFlowLayoutInvalidationContext methods

extension ProfileViewController: UICollectionViewDelegateFlowLayout {

}

// MARK: - ProfileHeaderCollectionReusableViewDelegate methods

extension ProfileViewController: ProfileHeaderCollectionReusableViewDelegate {
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView, didTapPrimaryButtonWith viewModel: ProfileHeaderViewModel) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }

        if self.user.username == currentUsername {
            // Edit profile
        }
        else {
            // Follow or unfollow the current users profile being viewed
        }
    }
    
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView, didTapFollowersButtonWith viewModel: ProfileHeaderViewModel) {

    }
    
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView, didTapFollowingButtonWith viewModel: ProfileHeaderViewModel) {

    }

    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView, didTapAvatarFor viewModel: ProfileHeaderViewModel) {
        guard isCurrentUserProfile else { return }

        let actionSheet = UIAlertController(
            title: "Profile Picture",
            message: nil,
            preferredStyle: .actionSheet
        )
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            DispatchQueue.main.async {
                self.presentProfilePicturePicker(type: .camera)
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            DispatchQueue.main.async {
                self.presentProfilePicturePicker(type: .photoLibrary)
            }
        }))

        present(actionSheet, animated: true)
    }

    func presentProfilePicturePicker(type: PicturePickerModel) {
        let picker = UIImagePickerController()
        picker.sourceType = type == .camera ? .camera : .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true

        present(picker, animated: true)
    }

}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate methods

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }

        // Upload and update UI
        ProgressHUD.show("Uploading")
        StorageManager.shared.uploadProfilePicture(with: image) { [weak self] result in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }

                switch result {
                case .success(let downloadURL):
                    UserDefaults.standard.setValue(downloadURL.absoluteString, forKey: "profile_image_url")

                    strongSelf.user = User(
                        username: strongSelf.user.username,
                        profilePictureURL: downloadURL,
                        identifier: strongSelf.user.username
                    )
                    ProgressHUD.showSuccess("Updated!")
                    strongSelf.collectionView.reloadData()
                case .failure:
                    ProgressHUD.showError("Failed to update profile picture.")
                }
            }
        }
    }
}
