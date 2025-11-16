//
//  RevenueCat.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/13/25.
//

import RevenueCat

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
