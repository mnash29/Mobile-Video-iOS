//
//  HapticsManager.swift
//  TikTok
//
//  Created by mnash29 on 10/9/23.
//

import Foundation
import UIKit

final class HapticsManager {
    static let shared = HapticsManager()

    private init() {}

    // Public methods
    public func vibrateForSeletion() {
        DispatchQueue.main.async {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }

    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(type)
        }
    }
}
