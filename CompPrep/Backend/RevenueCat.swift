//
//  RevenueCat.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/13/25.
//

import RevenueCat
import Foundation
import Combine
import SwiftData

@MainActor
class CustomerInfoManager: ObservableObject {
    @Published var customerInfo: CustomerInfo?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasProAccess = false
    @Published var isOnTrial = false
    @Published var daysRemainingInTrial: Int?
    @Published var subscriptionType: String?

    private var modelContext: ModelContext?
    private var customerInfoTask: Task<Void, Never>?

    init() {
        // Listen for real-time updates from RevenueCat
        startListeningForCustomerInfoUpdates()
    }

    deinit {
        customerInfoTask?.cancel()
    }

    private func startListeningForCustomerInfoUpdates() {
        customerInfoTask = Task { [weak self] in
            for await customerInfo in Purchases.shared.customerInfoStream {
                guard let self = self else { return }
                await self.handleCustomerInfoUpdate(customerInfo)
            }
        }
    }

    private func handleCustomerInfoUpdate(_ customerInfo: CustomerInfo) async {
        self.customerInfo = customerInfo
        let currentHasAccess = !customerInfo.entitlements.active.isEmpty

        #if DEBUG
        print("🔐 Real-time Customer Info Update: hasProAccess = \(currentHasAccess)")
        print("🔐 Active entitlements: \(customerInfo.entitlements.active.keys)")
        #endif

        self.hasProAccess = currentHasAccess
        processEntitlements(from: customerInfo, currentHasAccess: currentHasAccess)
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadCachedSubscriptionStatus()
    }

    /// Update the manager directly from a CustomerInfo object (e.g., from paywall callbacks)
    func updateFromCustomerInfo(_ customerInfo: CustomerInfo) {
        self.customerInfo = customerInfo
        let currentHasAccess = !customerInfo.entitlements.active.isEmpty
        
        #if DEBUG
        print("🔐 Direct CustomerInfo Update: hasProAccess = \(currentHasAccess)")
        print("🔐 Active entitlements: \(customerInfo.entitlements.active.keys)")
        print("🔐 ALL entitlements: \(customerInfo.entitlements.all.keys)")
        print("🔐 Active subscriptions: \(customerInfo.activeSubscriptions)")
        print("🔐 All purchased product IDs: \(customerInfo.allPurchasedProductIdentifiers)")
        for (key, entitlement) in customerInfo.entitlements.all {
            print("🔐 Entitlement '\(key)': isActive=\(entitlement.isActive), productId=\(entitlement.productIdentifier)")
        }
        #endif
        
        let wasProUser = hasProAccess
        
        if currentHasAccess && !wasProUser {
            AnalyticsManager.shared.trackSubscriptionStarted(tier: "pro")
        } else if !currentHasAccess && wasProUser {
            AnalyticsManager.shared.trackSubscriptionCancelled()
        }
        
        hasProAccess = currentHasAccess
        processEntitlements(from: customerInfo, currentHasAccess: currentHasAccess)
    }

    private func loadCachedSubscriptionStatus() {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<SubscriptionEntity>()
        if let cached = try? context.fetch(descriptor).first {
            hasProAccess = cached.hasProAccess
            isOnTrial = cached.isOnTrial
            daysRemainingInTrial = cached.daysRemainingInTrial
            subscriptionType = cached.subscriptionType
        }
    }
    
    func checkEntitlement() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            if customerInfo.entitlements.all["CompPrep Pro"]?.isActive == true {
                // User has access to entitlement
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    @MainActor
    func fetchCustomerInfo() async {
        isLoading = true
        errorMessage = nil

        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            
            self.customerInfo = customerInfo
            
            let wasProUser = hasProAccess
            let currentHasAccess = !customerInfo.entitlements.active.isEmpty

            #if DEBUG
            print("🔐 Customer Info Updated: hasProAccess = \(currentHasAccess)")
            print("🔐 Active entitlements: \(customerInfo.entitlements.active.keys)")
            #endif

            if currentHasAccess && !wasProUser {
                AnalyticsManager.shared.trackSubscriptionStarted(tier: "pro")
            } else if !currentHasAccess && wasProUser {
                AnalyticsManager.shared.trackSubscriptionCancelled()
            }

            hasProAccess = currentHasAccess
            processEntitlements(from: customerInfo, currentHasAccess: currentHasAccess)

        } catch {
            errorMessage = error.localizedDescription
            #if DEBUG
            print("Error fetching customer info: \(error)")
            #endif
        }

        isLoading = false
    }

    private func processEntitlements(from customerInfo: CustomerInfo, currentHasAccess: Bool) {
        var trialStart: Date?
        var trialEnd: Date?
        var subType: String?
        var onTrial = false

        if let proEntitlement = customerInfo.entitlements.active["CompPrep Pro"] {
            if proEntitlement.periodType == .trial {
                onTrial = true
                trialEnd = proEntitlement.expirationDate

                if let endDate = trialEnd {
                    trialStart = Calendar.current.date(byAdding: .day, value: -3, to: endDate)
                }
            }

            if proEntitlement.productIdentifier.contains("yearly") {
                subType = "yearly"
            } else if proEntitlement.productIdentifier.contains("monthly") {
                subType = "monthly"
            }
        }

        isOnTrial = onTrial
        subscriptionType = subType
        daysRemainingInTrial = onTrial ? calculateDaysRemaining(until: trialEnd) : nil

        cacheSubscriptionStatus(
            hasAccess: currentHasAccess,
            onTrial: onTrial,
            trialStart: trialStart,
            trialEnd: trialEnd,
            subType: subType
        )
    }

    private func calculateDaysRemaining(until date: Date?) -> Int? {
        guard let endDate = date else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: endDate)
        return max(0, components.day ?? 0)
    }

    private func cacheSubscriptionStatus(
        hasAccess: Bool,
        onTrial: Bool,
        trialStart: Date?,
        trialEnd: Date?,
        subType: String?
    ) {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<SubscriptionEntity>()
        let cached = try? context.fetch(descriptor).first

        if let existing = cached {
            existing.hasProAccess = hasAccess
            existing.isOnTrial = onTrial
            existing.trialStartDate = trialStart
            existing.trialEndDate = trialEnd
            existing.subscriptionType = subType
            existing.lastUpdated = Date()
        } else {
            let newEntity = SubscriptionEntity(
                hasProAccess: hasAccess,
                isOnTrial: onTrial,
                trialStartDate: trialStart,
                trialEndDate: trialEnd,
                subscriptionType: subType
            )
            context.insert(newEntity)
        }

        try? context.save()
    }
}
