//
//  RevenueCat.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/13/25.
//

import RevenueCat
import Foundation
import Combine

class CustomerInfoManager: ObservableObject {
    @Published var customerInfo: CustomerInfo?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasProAccess = false
    
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

            if currentHasAccess && !wasProUser {
                AnalyticsManager.shared.trackSubscriptionStarted(tier: "pro")
            } else if !currentHasAccess && wasProUser {
                AnalyticsManager.shared.trackSubscriptionCancelled()
            }

            hasProAccess = currentHasAccess

        } catch {
            errorMessage = error.localizedDescription
            #if DEBUG
            print("Error fetching customer info: \(error)")
            #endif
        }

        isLoading = false
    }
}
