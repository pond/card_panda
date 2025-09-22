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

    @State private var showingAddCard = false

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
                        
                        Button(action: {
                            showingAddCard = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Card")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)

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
                }
            }
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddCard = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCard) {
                UnifiedAddCardView()
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
        showingAddCard = false
    }

    private func deleteCards(offsets: IndexSet) {
        withAnimation {
            offsets.map { cards[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
}

#Preview {
    CardListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
