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

    private init() {}

    enum SignInMethod {
        case email
        case facebook
        case google
    }

    // Public methods
    public func signIn(with method: SignInMethod) {

    }

    public func signOut() {}
}
