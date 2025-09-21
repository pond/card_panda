//
//  Card_PandaApp.swift
//  Card Panda
//
//  Created by Andrew Hodgkinson on 19/09/2025.
//
import SwiftUI
import CloudKit
import CoreData

@main
struct LoyaltyCardApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            CardListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
