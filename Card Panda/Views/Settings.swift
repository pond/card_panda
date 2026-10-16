//
//  Settings.swift
//  Card Panda
//
//  Created by Andrew Hodgkinson on 16/10/2026.
//
import SwiftUI

struct Settings: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(Constants.colourBoostKey) private var savedStops = Constants.defaultColourBoost
    @State private var stops = Constants.defaultColourBoost

    private let steps  = [0.0, 1.0, 2.0]
    private let red    = Color(red: 1, green: 0, blue: 0)
    private let green  = Color(red: 0, green: 1, blue: 0)
    private let blue   = Color(red: 0, green: 0, blue: 1)
    private let yellow = Color(red: 1, green: 1, blue: 0)

    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(spacing: 16) {
                        HStack(spacing: 24) {
                            ForEach([red, green, blue, yellow], id: \.self) { c in
                                swatch(c, stops)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        Slider(value: $stops, in: 0...2)

                        Text("\(stops, specifier: "%.2f") stops")
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Colour boost")
                }

                Section {
                    VStack(spacing: 16) {
                        row(red, green)
                        row(blue, yellow)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Examples")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if #available(iOS 26, *) {
                        Button(role: .cancel) { dismiss() }
                    } else {
                        Button("Cancel") { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if #available(iOS 26, *) {
                        Button(role: .confirm) { save() }
                            .disabled(stops == savedStops)
                    } else {
                        Button("Save") { save() }
                            .disabled(stops == savedStops)
                    }
                }
            }
            .onAppear { stops = savedStops }
        }
    }

    private func row(_ left: Color, _ right: Color) -> some View {
        HStack(spacing: 0) {
            Spacer()
            group(left)
            Spacer()
            group(right)
            Spacer()
        }
    }

    private func group(_ color: Color) -> some View {
        HStack(spacing: 12) {
            ForEach(steps, id: \.self) { s in
                VStack(spacing: 4) {
                    swatch(color, s)
                    Text("\(s, specifier: "%.1f")").font(.caption2)
                }
                .frame(width: 28)
            }
        }
    }

    private func swatch(_ color: Color, _ s: Double) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(boosted(color, s))
            .frame(width: 8, height: 40)
    }

    private func boosted(_ color: Color, _ s: Double) -> Color {
        if #available(iOS 26, *) { return color.exposureAdjust(s) }
        return color
    }

    private func save() {
        savedStops = stops
        dismiss()
    }
}
