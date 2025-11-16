//
//  CompPrepApp.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/12/25.
//

import SwiftUI
import SwiftData
import RevenueCat
import RevenueCatUI

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
            DiceOptionsEntity.self,
            SubscriptionEntity.self
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
            MainAppView()
        }
        .modelContainer(sharedModelContainer)
    }
}

struct MainAppView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @StateObject private var customerManager = CustomerInfoManager()

    var body: some View {
        Group {
            if hasSeenOnboarding{
                ContentView()
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            customerManager.setModelContext(modelContext)
            Task {
                await customerManager.fetchCustomerInfo()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshSubscription"))) { _ in
            Task {
                await customerManager.fetchCustomerInfo()
            }
        }
    }
}
