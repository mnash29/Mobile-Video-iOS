//
//  StorageManager.swift
//  TikTok
//
//  Created by mnash29 on 10/9/23.
//

import UIKit
import FirebaseStorage

final class StorageManager {
    public static let shared = StorageManager()

    private let storageBucket = Storage.storage().reference()

    private init() {}

    private func getUsername() -> String? {
        return UserDefaults.standard.string(forKey: "username")
    }

    // MARK: - Public methods

    public func uploadVideo(from url: URL, fileName: String, completion: @escaping (Bool) -> Void) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        
        storageBucket.child("videos/\(username)/\(fileName)").putFile(from: url, metadata: nil) { _, error in
            completion(error == nil)
        }
    }

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

    public func generateVideoName() -> String {
        let uuidString = UUID().uuidString
        let number = Int.random(in: 0...1000)
        let unixTimestamp = Date().timeIntervalSince1970

        return  "\(uuidString)_\(number)_\(unixTimestamp).mov"
    }

}
