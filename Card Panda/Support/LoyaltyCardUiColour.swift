//
//  LoyaltyCardUiColour.swift
//  Card Panda
//
//  Created by Andrew Hodgkinson on 21/09/2025.
//
import SwiftUI

extension LoyaltyCard {
    var uiColor: Color {
        get {
            if let colourData = self.colour,
               let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colourData) {
                return Color(uiColor)
            }
            return Constants.defaultCardColour
        }
        set {
            let uiColor = UIColor(newValue)
            self.colour = try? NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
        }
    }
}
