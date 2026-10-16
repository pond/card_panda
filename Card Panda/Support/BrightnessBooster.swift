//
//  BrightnessBooster.swift
//  Card Panda
//
//  Created by Andrew Hodgkinson on 16/10/2026.
//
import SwiftUI
import UIKit

@MainActor
final class BrightnessBooster {
    private var saved: CGFloat? // not-nil => currently boosted
    private let level: CGFloat

    init(level: CGFloat = 0.9) { self.level = level }

    func boost() {
        guard saved == nil else { return } // (already boosted; don't re-capture)
        let current = UIScreen.main.brightness
        guard current < level else { return } // (don't dim a brighter screen)
        saved = current
        UIScreen.main.brightness = level
    }

    func restore() {
        guard let saved else { return }
        UIScreen.main.brightness = saved
        self.saved = nil
    }

    var isBoosted: Bool { saved != nil }

    deinit {
        if let saved { MainActor.assumeIsolated { UIScreen.main.brightness = saved } }
    }
}
