//
//  CardSwatch.swift
//  Card Panda
//
//  Created by Andrew Hodgkinson on 16/10/2026.
//
//  HDR-boosted colour swatches for the card list view, in iOS 26 or later.
//
import SwiftUI

struct CardSwatch: View {
    let color: Color
    @AppStorage(Constants.colourBoostKey) private var stops = Constants.defaultColourBoost

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(hdr)
            .frame(width: 8, height: 40)
    }

    private var hdr: Color {
        if #available(iOS 26, *) {
            return color.exposureAdjust(stops)
        }
        return color
    }
}
