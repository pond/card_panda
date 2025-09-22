//
//  CardDetailView.swift
//  Card Panda
//
//  Created by Andrew Hodgkinson on 21/09/2025.
//
import SwiftUI
import CoreData

struct CardDetailView: View {
    @ObservedObject var card: LoyaltyCard
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @FocusState private var nameFieldFocused:    Bool
    @FocusState private var barcodeFieldFocused: Bool

    @State private var editingName        = false
    @State private var editingBarcode     = false
    @State private var newName            = ""
    @State private var newBarcode         = ""
    @State private var originalBrightness = UIScreen.main.brightness

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                if editingName {
                    VStack(spacing: 10) {
                        TextField("Card name", text: $newName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                            .autocorrectionDisabled()
                            .focused($nameFieldFocused)
                            .onAppear {
                                nameFieldFocused = true
                            }
                        HStack {
                            Button("Save") {
                                card.name = newName
                                PersistenceController.shared.save()
                                try? viewContext.save()
                                editingName = false
                            }
                            .buttonStyle(.borderedProminent)
                            Button("Cancel") {
                                editingName = false
                                newName = card.name ?? "Unknown"
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                } else {
                    HStack {
                        ColorPicker("", selection: Binding(
                            get: { card.uiColor },
                            set: { newColor in
                                card.uiColor = newColor
                                try? viewContext.save()
                            }
                        ))
                        .labelsHidden()

                        Text(card.name ?? "Unknown")
                            .font(.title)
                        Spacer()
                        Button("Edit") {
                            newName = card.name ?? ""
                            editingName = true
                        }
                    }
                    .padding()
                }

                BarcodeView(barcode: card.barcode ?? "", type: card.barcodeType ?? "code128")
                    .frame(height: 200)

                if editingBarcode {
                    VStack(spacing: 10) {
                        TextField("Barcode number", text: $newBarcode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numbersAndPunctuation)
                            .autocorrectionDisabled()
                            .focused($barcodeFieldFocused)
                            .onAppear {
                                barcodeFieldFocused = true
                            }
                        HStack {
                            Button("Save") {
                                card.barcode = newBarcode
                                try? viewContext.save()
                                editingBarcode = false
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(newBarcode.isEmpty)
                            Button("Cancel") {
                                editingBarcode = false
                                newBarcode = card.barcode ?? ""
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                } else {
                    VStack {
                        Text(card.barcode ?? "")
                            .font(.system(.body, design: .monospaced))
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        Button("Edit") {
                            newBarcode = card.barcode ?? ""
                            editingBarcode = true
                        }
                    }
                    .padding(.vertical)
                }

                Spacer(minLength: 100)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            originalBrightness = UIScreen.main.brightness
            UIScreen.main.brightness = 0.9
        }
        .onWillDisappear {
            UIScreen.main.brightness = originalBrightness
        }
    }
}
