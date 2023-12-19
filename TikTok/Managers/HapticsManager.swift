//
//  HapticsManager.swift
//  TikTok
//
//  Created by mnash29 on 10/9/23.
//

import Foundation
import UIKit

/// Manager that deals with haptic feedback
final class HapticsManager {
    /// Shared singleton instance of the `HapticsManager`
    static let shared = HapticsManager()

    private init() {}

    // Public methods

    /// Vibrate for light selection of item
    public func vibrateForSeletion() {
        DispatchQueue.main.async {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
    
    /// Trigger feedback vibration based on event type
    /// - Parameter type: Success, Error, or Warning feedback types
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(type)
        }
    }
}
