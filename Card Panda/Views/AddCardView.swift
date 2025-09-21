//
//  AddCardView.swift
//  Card Panda
//
//  Created by Andrew Hodgkinson on 21/09/2025.
//
import SwiftUI
import CoreData

struct AddCardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @FocusState private var isFocused: Bool

    @State private var name    = ""
    @State private var barcode = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Card name", text: $name)
                    .textContentType(.name)
                    .autocapitalization(.words)
                    .focused($isFocused)
                    .onAppear {
                        isFocused = true
                    }
                TextField("Barcode number", text: $barcode)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("Add Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newCard = LoyaltyCard(context: viewContext)
                        newCard.name = name.isEmpty ? "Card" : name
                        newCard.barcode = barcode
                        newCard.barcodeType = "code128"
                        newCard.dateAdded = Date()

                        PersistenceController.shared.save()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(barcode.isEmpty)
                }
            }
        }
    }
}
