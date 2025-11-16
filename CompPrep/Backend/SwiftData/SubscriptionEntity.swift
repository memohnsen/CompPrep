//
//  SubscriptionEntity.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/16/25.
//

import SwiftData
import Foundation

@Model
class SubscriptionEntity {
    @Attribute(.unique) var id: Int
    var hasProAccess: Bool
    var isOnTrial: Bool
    var trialStartDate: Date?
    var trialEndDate: Date?
    var subscriptionType: String? // monthly, lifetime, or nil
    var lastUpdated: Date

    init(
        id: Int = 1,
        hasProAccess: Bool = false,
        isOnTrial: Bool = false,
        trialStartDate: Date? = nil,
        trialEndDate: Date? = nil,
        subscriptionType: String? = nil,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.hasProAccess = hasProAccess
        self.isOnTrial = isOnTrial
        self.trialStartDate = trialStartDate
        self.trialEndDate = trialEndDate
        self.subscriptionType = subscriptionType
        self.lastUpdated = lastUpdated
    }

    var daysRemainingInTrial: Int? {
        guard isOnTrial, let endDate = trialEndDate else { return nil }
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: now, to: endDate)
        return max(0, components.day ?? 0)
    }
}
