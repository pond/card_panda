//
//  CardListView.swift
//  Card Panda
//
//  Created by Andrew Hodgkinson on 19/09/2025.
//

import SwiftUI
import CoreData

struct CardListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LoyaltyCard.name, ascending: true)],
        animation: .default)
    private var cards: FetchedResults<LoyaltyCard>

    @State private var showingScanner = false
    @State private var showingAddCard = false

    var body: some View {
        NavigationView {
            List {
                ForEach(cards, id: \.objectID) { card in
                    NavigationLink(destination: CardDetailView(card: card)) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(card.uiColor)
                            .frame(width: 8, height: 40)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(card.name ?? "Unknown")
                                .font(.headline)
                            Text(card.barcode ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
                .onDelete(perform: deleteCards)
            }
            .navigationTitle("Card Panda")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Scan Barcode") {
                            showingScanner = true
                        }
                        Button("Add Manually") {
                            showingAddCard = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                BarcodeScannerView { barcode, symbology in
                    let type = BarcodeUtils.barcodeSymbologyToInternalType(symbology)
                    addCard(barcode: barcode, type: type)
                }
                .ignoresSafeArea(.all)
            }
            .sheet(isPresented: $showingAddCard) {
                AddCardManuallyView()
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
                viewContext.refreshAllObjects()
            }
        }
    }

    private func addCard(barcode: String, type: String = "code128") {
        let newCard = LoyaltyCard(context: viewContext)
        newCard.name = "Card \(cards.count + 1)"
        newCard.barcode = barcode
        newCard.barcodeType = type
        newCard.dateAdded = Date()

        try? viewContext.save()
        showingScanner = false
    }

    private func deleteCards(offsets: IndexSet) {
        withAnimation {
            offsets.map { cards[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }

    private func addItem(name: String? = nil, barcode: String, type: String = "code128") {
        withAnimation {
            let newCard = LoyaltyCard(context: viewContext)

            newCard.name = name ?? "Card \(cards.count + 1)"
            newCard.barcode = barcode
            newCard.barcodeType = type
            newCard.dateAdded = Date()

            do {
                try viewContext.save()
            } catch {
                // UnfixableError().display(message: "Couldn't save the card due to an unexpected and unrecoverable error", using: self)
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { cards[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#Preview {
    CardListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
