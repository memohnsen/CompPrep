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
    @StateObject private var timerManager = TimerManager()
    @State private var showLaunchScreen = true

    var body: some View {
        ZStack {
            if !hasSeenOnboarding {
                OnboardingView()
                    .environmentObject(customerManager)
            } else {
                ContentView()
                    .environmentObject(timerManager)
                    .environmentObject(customerManager)
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshSubscription"))) { _ in
                        Task {
                            await customerManager.fetchCustomerInfo()
                        }
                    }
            }

            if showLaunchScreen {
                LaunchScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            // Set context and fetch ONCE at the root level
            customerManager.setModelContext(modelContext)
            Task {
                await customerManager.fetchCustomerInfo()
            }
            
            // Dismiss launch screen after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showLaunchScreen = false
                }
            }
        }
    }
}
