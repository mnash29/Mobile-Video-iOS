//
//  NotificationsViewController.swift
//  TikTok
//
//  Created by mnash29 on 10/9/23.
//

import UIKit

class NotificationsViewController: UIViewController, UITableViewDelegate {

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

        tableView.delegate = self
        tableView.dataSource = self

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

}

// MARK: - NotificationViewController datasource methods
extension NotificationsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = notifications[indexPath.row]
        let basicCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        switch model.type {

        case .postLike(postName: let postName):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NotificationPostLikeTableViewCell.identifier,
                for: indexPath
            ) as? NotificationPostLikeTableViewCell else {
                return basicCell
            }
            cell.configure(with: postName)
            return cell
        case .userFollow(username: let username):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NotificationUserFollowTableViewCell.identifier,
                for: indexPath
            ) as? NotificationUserFollowTableViewCell else {
                return basicCell
            }
            cell.configure(with: username)
            return cell
        case .postComment(postName: let postName):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NotificationPostCommentTableViewCell.identifier,
                for: indexPath
            ) as? NotificationPostCommentTableViewCell else {
                return basicCell
            }
            cell.configure(with: postName)
            return cell
        }
    }
}
