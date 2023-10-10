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

    private let database = Storage.storage().reference()

    private init() {}

    // Public methods
    public func getVideoUrl(with identfier: String, completion: (URL) -> Void) {

    }

    public func uploadVideoURL(from url: URL) {

    }
}
