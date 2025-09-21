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
    @State private var showingScanFromCameraRoll = false
    @State private var showingAddManually = false

    var body: some View {
        NavigationView {
            Group {
                if cards.isEmpty {
                    VStack(spacing: 30) {
                        Spacer()

                        Text("Card Panda")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)

                        Spacer()
                        
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gray.opacity(0.4))
                        
                        VStack(spacing: 12) {
                            Text("No Cards Yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Scan your first card barcode to get started")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        
                        VStack(spacing: 16) {
                            Button(action: {
                                showingScanner = true
                            }) {
                                HStack {
                                    Image(systemName: "barcode.viewfinder")
                                    Text("Scan Barcode")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 40)
                            
                            Button(action: {
                                showingAddManually = true
                            }) {
                                HStack {
                                    Image(systemName: "keyboard")
                                    Text("Add Manually")
                                }
                                .font(.headline)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 40)
                        }
                        
                        Spacer()
                        Spacer()
                        Spacer()
                    }
                    .transition(.opacity)
                }
                else {
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
                                Button("Scan A Photo") {
                                    showingScanFromCameraRoll = true
                                }
                                Button("Add Manually") {
                                    showingAddManually = true
                                }
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
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
            .sheet(isPresented: $showingScanFromCameraRoll) {
                CameraRollScannerView { barcode, symbology in
                    let type = BarcodeUtils.barcodeSymbologyToInternalType(symbology)
                    addCard(barcode: barcode, type: type)
                }
            }
            .sheet(isPresented: $showingAddManually) {
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
