//
//  Haptic.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/11.
//

import SwiftUI

struct Haptic {
    static func trigger(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}
