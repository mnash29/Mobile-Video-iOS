//
//  StorageManager.swift
//  TikTok
//
//  Created by mnash29 on 10/9/23.
//

import UIKit
import FirebaseStorage

/// Manager object that deals with Firebase storage operations
final class StorageManager {
    /// Shared singleton instance of the StorageManager
    public static let shared = StorageManager()
    
    /// Storage bucket reference
    private let storageBucket = Storage.storage().reference()

    private init() {}

    private func getUsername() -> String? {
        return UserDefaults.standard.string(forKey: "username")
    }

    // MARK: - Public methods
    
    /// Upload a new user video to Firebase
    /// - Parameters:
    ///   - url: Local file URL to video
    ///   - fileName: Desired video file upload name
    ///   - completion: Async callback result closure
    public func uploadVideo(from url: URL, fileName: String, completion: @escaping (Bool) -> Void) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        
        storageBucket.child("videos/\(username)/\(fileName)").putFile(from: url, metadata: nil) { _, error in
            completion(error == nil)
        }
    }
    
    /// Upload a new user profile picture
    /// - Parameters:
    ///   - image: The UIImage to upload
    ///   - completion: Async callback of Result
    public func uploadProfilePicture(with image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let username = getUsername() else { return }

        guard let imageData = image.pngData() else { return }

        let path = "profile_pictures/\(username)/image.png"

        storageBucket.child(path).putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
            }
            else {
                self.storageBucket.child(path).downloadURL { url, error in
                    guard let url = url else {
                        if let error = error {
                            completion(.failure(error))
                        }
                        return
                    }

                    completion(.success(url))
                }
            }
        }
    }
    
    /// Generate a new file name
    /// - Returns: Return a unique generated filename
    public func generateVideoName() -> String {
        let uuidString = UUID().uuidString
        let number = Int.random(in: 0...1000)
        let unixTimestamp = Date().timeIntervalSince1970

        return  "\(uuidString)_\(number)_\(unixTimestamp).mov"
    }
    
    /// Get download URL of video post
    /// - Parameters:
    ///   - post: Post model to URL for
    ///   - completion: Async callback of Result
    func getDownloadURL(for post: PostModel, completion: @escaping (Result<URL, Error>) -> Void) {
        storageBucket.child(post.videoChildPath).downloadURL { url, error in
            if let error = error {
                completion(.failure(error))
            } else if let url = url {
                completion(.success(url))
            }
        }
    }
}
