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

    public func getAllUsers(completion: ([String]) -> Void) {

    }

    public func insertPost(fileName: String, caption: String, completion: @escaping (Bool) -> Void) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
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
}
