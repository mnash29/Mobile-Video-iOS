//
//  StorageManager.swift
//  TikTok
//
//  Created by mnash29 on 10/9/23.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    public static let shared = StorageManager()

    private let storageBucket = Storage.storage().reference()

    private init() {}

    // Public methods
    public func getVideoUrl(with identfier: String, completion: (URL) -> Void) {

    }

    public func uploadVideo(from url: URL, fileName: String, completion: @escaping (Bool) -> Void) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        
        storageBucket.child("videos/\(username)/\(fileName)").putFile(from: url, metadata: nil) { _, error in
            completion(error == nil)
        }
    }

    public func generateVideoName() -> String {
        let uuidString = UUID().uuidString
        let number = Int.random(in: 0...1000)
        let unixTimestamp = Date().timeIntervalSince1970

        return  "\(uuidString)_\(number)_\(unixTimestamp).mov"
    }
}
