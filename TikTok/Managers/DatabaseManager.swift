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

    public func getAllUsers(completion: ([String]) -> Void) {

    }
}
