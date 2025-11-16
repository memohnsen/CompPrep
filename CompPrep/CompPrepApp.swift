//
//  CompPrepApp.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/12/25.
//

import SwiftUI
import SwiftData
import RevenueCat

@main
struct CompPrepApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        let revenueCatKey = Bundle.main.object(forInfoDictionaryKey: "REVENUECAT_API_KEY") as! String
        Purchases.configure(withAPIKey: revenueCatKey)
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
