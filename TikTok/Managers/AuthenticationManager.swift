//
//  AuthenticationManager.swift
//  TikTok
//
//  Created by mnash29 on 10/9/23.
//

import Foundation
import FirebaseAuth

final class AuthManager {
    public static let shared = AuthManager()

    // MARK: - Init

    private init() {}

    enum SignInMethod {
        case email
        case facebook
        case google
    }

    enum AuthError: Error {
        case signInFailed
    }

    // MARK: Public methods

    public var isSignedIn: Bool {
        return Auth.auth().currentUser != nil
    }

    public func signIn(with email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            guard result != nil, error == nil else {
                if let error = error {
                    completion(.failure(error))
                }
                else {
                    completion(.failure(AuthError.signInFailed))
                }
                return
            }

            // Get username to cache
            DatabaseManager.shared.getUsername(for: email) { username in
                if let username = username {
                    UserDefaults.standard.setValue(username, forKey: "username")
                    print("Got username: \(username)")
                }
            }

            // Successful sign-in
            completion(.success(email))
        }
    }

    public func signUp(
        with username: String,
        emailAddress: String,
        password: String,
        completion: @escaping (Bool) -> Void
    ) {
        // Ensure username is available

        Auth.auth().createUser(withEmail: emailAddress,
                               password: password
        ) { result, error in
            guard result != nil, error == nil else {
                completion(false)
                return
            }

            UserDefaults.standard.setValue(username, forKey: "username")
            DatabaseManager.shared.insertUser(with: emailAddress,
                                              username: username,
                                              completion: completion)
        }
    }

    public func signOut(completion: (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
        }
        catch {
            print(error)
            completion(false)
        }
    }
}
