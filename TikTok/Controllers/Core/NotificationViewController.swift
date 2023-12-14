//
//  NotificationViewController.swift
//  TikTok
//
//  Created by mnash29 on 10/9/23.
//

import UIKit

class NotificationViewController: UIViewController, UITableViewDelegate {

    private let noNotificationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.text = "No Notifications"
        label.isHidden = true
        label.textAlignment = .center

        return label
    }()

    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "cell"
        )
        table.register(
            NotificationUserFollowTableViewCell.self,
            forCellReuseIdentifier: NotificationUserFollowTableViewCell.identifier
        )
        table.register(
            NotificationPostLikeTableViewCell.self,
            forCellReuseIdentifier: NotificationPostLikeTableViewCell.identifier
        )
        table.register(
            NotificationPostCommentTableViewCell.self,
            forCellReuseIdentifier: NotificationPostCommentTableViewCell.identifier
        )

        return table
    }()

    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.tintColor = .label
        spinner.startAnimating()
        
        return spinner
    }()

    var notifications = [Notification]()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(noNotificationLabel)
        view.addSubview(spinner)

        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = control

        fetchNotifications()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.frame = view.bounds
        noNotificationLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: 200,
            height: 200
        )
        noNotificationLabel.center = view.center

        spinner.frame = CGRect(
            x: 0,
            y: 0,
            width: 100,
            height: 100
        )
        spinner.center = view.center
    }

    func fetchNotifications() {
        DatabaseManager.shared.getNotifications { [weak self] notifications in
            DispatchQueue.main.async {
                self?.spinner.stopAnimating()
                self?.spinner.isHidden = true
                self?.notifications = notifications
                self?.updateUI()
            }
        }
    }

    func updateUI() {
        if notifications.isEmpty {
            noNotificationLabel.isHidden = false
            tableView.isHidden = true
        }
        else {
            noNotificationLabel.isHidden = true
            tableView.isHidden = false
        }

        tableView.reloadData()
    }

    func openPost(with identifier: String) {
        let vc = PostViewController(model: PostModel(
            identifier: identifier,
            user: User(
                username: "kanyewest",
                profilePictureURL: nil,
                identifier: UUID().uuidString
            )
        ))
        vc.delegate = self
        vc.title = "Video"
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func didPullToRefresh(_ sender: UIRefreshControl) {
        sender.beginRefreshing()

        DatabaseManager.shared.getNotifications { [weak self] notifications in
            DispatchQueue.main.async {
                self?.notifications = notifications
                self?.tableView.reloadData()
                sender.endRefreshing()
            }
        }
    }

}

// MARK: - NotificationViewController datasource methods
extension NotificationViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = notifications[indexPath.row]

        switch model.type {

        case .postLike(postName: let postName):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NotificationPostLikeTableViewCell.identifier,
                for: indexPath
            ) as? NotificationPostLikeTableViewCell else {
                return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            }
            cell.delegate = self
            cell.configure(with: postName, model: model)
            return cell
        case .userFollow(username: let username):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NotificationUserFollowTableViewCell.identifier,
                for: indexPath
            ) as? NotificationUserFollowTableViewCell else {
                return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            }
            cell.delegate = self
            cell.configure(with: username, model: model)
            return cell
        case .postComment(postName: let postName):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NotificationPostCommentTableViewCell.identifier,
                for: indexPath
            ) as? NotificationPostCommentTableViewCell else {
                return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            }
            cell.delegate = self
            cell.configure(with: postName, model: model)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }

        let model = notifications[indexPath.row]
        model.isHidden = true

        DatabaseManager.shared.markNotificationAsHidden(notificationID: model.identifier) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    // filter out hidden notifications in array
                    self?.notifications = self?.notifications.filter({ $0.isHidden == false }) ?? []

                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .none)
                    tableView.endUpdates()
                }
            }
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - NotificationUserFollowTableViewCellDelegate methods

extension NotificationViewController: NotificationUserFollowTableViewCellDelegate {
    func notificationUserFollowTableViewCell(_ cell: NotificationUserFollowTableViewCell, didTapFollowFor username: String) {
        DatabaseManager.shared.follow(username: username) { success in
            if !success {
                print("Something failed")
            }
        }
    }
    
    func notificationUserFollowTableViewCell(_ cell: NotificationUserFollowTableViewCell, didTapAvatarFor username: String) {
        let vc = ProfileViewController(
            user: User(
                username: username,
                profilePictureURL: nil,
                identifier: "123"
            )
        )
        vc.title = username.uppercased()
        navigationController?.pushViewController(vc, animated: true)
    }

}

// MARK: - NotificationPostLikeTableViewCellDelegate methods

extension NotificationViewController: NotificationPostLikeTableViewCellDelegate {
    func notificationPostLikeTableViewCell(_ cell: NotificationPostLikeTableViewCell, didTapPostWith identifier: String) {
        openPost(with: identifier)
    }
}

// MARK: - NotificationPostCommentTableViewCellDelegate methods

extension NotificationViewController: NotificationPostCommentTableViewCellDelegate {
    func notificationPostCommentTableViewCell(_ cell: NotificationPostCommentTableViewCell, didTapPostWith identifier: String) {
        openPost(with: identifier)
    }
}

// MARK: - PostViewControllerDelegate methods

extension NotificationViewController: PostViewControllerDelegate {
    func postViewController(_ vc: PostViewController, didTapCommentButtonFor post: PostModel) {
        print("NotificationViewController.didTapCommentButtonFor not configured.")
    }
    
    func postViewController(_ vc: PostViewController, didTapProfileButtonFor post: PostModel) {
        let user = post.user
        let vc = ProfileViewController(user: user)

        navigationController?.pushViewController(vc, animated: true)
    }

}
