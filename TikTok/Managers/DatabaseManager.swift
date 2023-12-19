//
//  DatabaseManager.swift
//  TikTok
//
//  Created by mnash29 on 10/9/23.
//

import Foundation
import FirebaseDatabase

/// Manager for database operations
final class DatabaseManager {
    /// Shared singleton instance of the `DatabaseManager`
    public static let shared = DatabaseManager()

    /// Reference to the `Database` object
    private let database = Database.database().reference()

    private init() {}

    /// Represents the currently signed in username
    /// - Returns: Return the current username signed in
    private func getUserDefaultUsername() -> String? {
        return UserDefaults.standard.string(forKey: "username")
    }

    // Public methods

    /// Attempt to insert a new user object
    /// - Parameters:
    ///   - email: The user email address
    ///   - username: The user name
    ///   - completion: Async callback of type `Bool`
    public func insertUser(with email: String, username: String, completion: @escaping (Bool) -> Void) {
        // Get current users key
        database.child("users").observeSingleEvent(of: .value) { [weak self] snapshot, _  in
            guard var usersDictionary = snapshot.value as? [String: Any] else {
                // Create root users node
                self?.database.child("users").setValue(
                    [
                        username: [
                            "email": email
                        ]
                    ]
                ) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }

                    completion(true)
                }
                return
            }

            usersDictionary[username] = ["email": email]

            // Insert new entry
            self?.database.child("users").setValue(usersDictionary, withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }

                completion(true)
            })
        }
    }

    /// Get the username for a given email
    /// - Parameters:
    ///   - email: The email address to query
    ///   - completion: Async callback of type `Result`
    public func getUsername(for email: String, completion: @escaping (String?) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { snapshot, _  in
            guard let users = snapshot.value as? [String: [String: Any]] else {
                completion(nil)
                return
            }

            for (username, value) in users {
                if value["email"] as? String == email {
                    completion(username)
                    break
                }
            }
        }
    }

    /// Get current user's notifications
    /// - Parameter completion: Async callback of type `[Notification]`
    public func getNotifications(completion: @escaping ([Notification]) -> Void) {
        completion(Notification.mockData())
    }

    /// Mark a notification as hidden
    /// - Parameters:
    ///   - notificationID: Notification identifier
    ///   - completion: Async callback for type `Bool`
    public func markNotificationAsHidden(notificationID: String, completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    /// Attempt to insert a new post
    /// - Parameters:
    ///   - fileName: File name to insert for post
    ///   - caption: Caption to insert for post
    ///   - completion: Async callback of type `Bool`
    public func insertPost(fileName: String, caption: String, completion: @escaping (Bool) -> Void) {
        guard let username = getUserDefaultUsername() else {
            completion(false)
            return
        }

        let newEntry = [
            "name": fileName,
            "caption": caption
        ]

        database.child("users").child(username).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard var value = snapshot.value as? [String: Any] else {
                completion(false)
                return
            }

            if var posts = value["posts"] as? [[String: Any]] {
                posts.append(newEntry)
                value["posts"] = posts
                self?.database.child("users").child(username).setValue(value) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
            } else {
                value["posts"] = [newEntry]
                self?.database.child("users").child(username).setValue(value) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
        }
    }

    /// Get all posts for a given user
    /// - Parameters:
    ///   - user: The user name
    ///   - completion: Async callback of type `[PostModel]`
    public func getPosts(for user: User, completion: @escaping ([PostModel]) -> Void) {
        let path = "users/\(user.username.lowercased())/posts"
        database.child(path).observeSingleEvent(of: .value) { snapshot in
            guard let posts = snapshot.value as? [[String: String]] else {
                completion([])
                return
            }

            let models: [PostModel] = posts.compactMap({
                var model = PostModel(
                    identifier: UUID().uuidString,
                    user: user
                )
                model.fileName = $0["name"] ?? ""
                model.caption = $0["caption"] ?? ""
                return model
            })

            completion(models)
        }
    }

    /// Get the target user relationship with current user
    /// - Parameters:
    ///   - user: Target user to check following status
    ///   - type: Type to be checked
    ///   - completion: Async callback of type `[String]`
    public func getRelationships(for user: User, type: UserListViewController.ListType, completion: @escaping ([String]) -> Void) {
        let path = "users/\(user.username.lowercased())/\(type.rawValue)"

        database.child(path).observeSingleEvent(of: .value) { snapshot in
            guard let usernameCollection = snapshot.value as? [String] else {
                completion([])
                return
            }

            completion(usernameCollection)
        }
    }

    /// Check if a relationship is valid
    /// - Parameters:
    ///   - user: Target user
    ///   - type: Type to check
    ///   - completion: Async callback of type `Bool`
    public func isValidRelationship(for user: User, type: UserListViewController.ListType, completion: @escaping (Bool) -> Void) {
        let path = "users/\(user.username.lowercased())/\(type.rawValue)"

        database.child(path).observeSingleEvent(of: .value) { snapshot  in
            guard let usernameCollection = snapshot.value as? [String] else {
                completion(false)
                return
            }

            completion(usernameCollection.contains(self.getUserDefaultUsername()?.lowercased() ?? ""))
        }
    }

    /// Update follow status for target user
    /// - Parameters:
    ///   - user: Target user
    ///   - follow: Follow or unfollow status
    ///   - completion: Async callback of type `Bool`
    public func updateRelationship(for user: User, follow: Bool, completion: @escaping (Bool) -> Void) {
        guard let currentUsername = getUserDefaultUsername()?.lowercased() else { return }

        let targetUserName = user.username.lowercased()

        if follow {
            // Insert into current users's following group
            let followingPath = "users/\(currentUsername)/following"
            database.child(followingPath).observeSingleEvent(of: .value) { snapshot in
                if var current = snapshot.value as? [String] {
                    current.append(targetUserName)
                    self.database.child(followingPath).setValue(current) { error, _ in
                        completion(error == nil)
                    }
                } else {
                    self.database.child(followingPath).setValue([targetUserName]) { error, _ in
                        completion(error == nil)
                    }
                }
            }

            // Insert in target user's followers group
            let followersPath = "users/\(targetUserName)/followers"
            database.child(followersPath).observeSingleEvent(of: .value) { snapshot in
                if var current = snapshot.value as? [String] {
                    current.append(currentUsername)
                    self.database.child(followersPath).setValue(current) { error, _ in
                        completion(error == nil)
                    }
                } else {
                    self.database.child(followersPath).setValue([currentUsername]) { error, _ in
                        completion(error == nil)
                    }
                }
            }
        } else {
            // Remove from  current users's following group
            let followingPath = "users/\(currentUsername)/following"
            database.child(followingPath).observeSingleEvent(of: .value) { snapshot in
                if var current = snapshot.value as? [String] {
                    current.removeAll(where: { $0 == targetUserName })
                    self.database.child(followingPath).setValue(current) { error, _ in
                        completion(error == nil)
                    }
                }
            }

            // Remove from target user's followers group
            let followersPath = "users/\(targetUserName)/followers"
            database.child(followersPath).observeSingleEvent(of: .value) { snapshot in
                if var current = snapshot.value as? [String] {
                    current.removeAll(where: { $0 == currentUsername })
                    self.database.child(followersPath).setValue(current) { error, _ in
                        completion(error == nil)
                    }
                }
            }
        }
    }
}
