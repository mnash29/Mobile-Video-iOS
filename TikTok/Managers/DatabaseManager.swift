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
    public func getAllUsers(completion: ([String]) -> Void) {

    }
}
