//
//  DatabaseManager.swift
//  TikTok
//
//  Created by mnash29 on 10/9/23.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    public static let shared = DatabaseManager()

    private let database = Database.database().reference()

    private init() {}

    private func getUserDefaultUsername() -> String? {
        return UserDefaults.standard.string(forKey: "username")
    }

    // Public methods

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

    public func getNotifications(completion: @escaping ([Notification]) -> Void) {
        completion(Notification.mockData())
    }

    public func markNotificationAsHidden(notificationID: String, completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    public func follow(username: String, completion: @escaping (Bool) -> Void) {
        completion(true)
    }

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
            }
            else {
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
        }
        else {
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
