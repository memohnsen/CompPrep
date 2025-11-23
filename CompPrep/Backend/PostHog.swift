//
//  PostHog.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/13/25.
//

import PostHog

class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() {}
    
    func trackScreenView(_ screenName: String, properties: [String: Any]? = nil) {
        PostHogSDK.shared.screen(screenName, properties: properties)
    }
    
    // MARK: - Comp Dice
    func trackDiceRolled(optionCount: Int, resultText: String) {
        PostHogSDK.shared.capture("dice_rolled", properties: [
            "option_count": optionCount,
            "result_text": resultText
        ])
    }

    // MARK: - Timer
    func trackTimerStarted(withCountdown: Bool, sets: Int, minRestMin: Int, maxRestMin: Int) {
        PostHogSDK.shared.capture("timer_started", properties: [
            "with_countdown": withCountdown,
            "sets": sets,
            "min_rest_min": minRestMin,
            "max_rest_min": maxRestMin
        ])
    }

    func trackTimerPaused(currentSet: Int, secondsRemaining: Int) {
        PostHogSDK.shared.capture("timer_paused", properties: [
            "current_set": currentSet,
            "seconds_remaining": secondsRemaining
        ])
    }

    func trackTimerReset(currentSet: Int) {
        PostHogSDK.shared.capture("timer_reset", properties: [
            "current_set": currentSet
        ])
    }

    func trackTimerCompleted(totalSets: Int) {
        PostHogSDK.shared.capture("timer_completed", properties: [
            "total_sets": totalSets
        ])
    }

    // MARK: - Settings
    func trackCustomerSupportOpened() {
        PostHogSDK.shared.capture("customer_support_opened")
    }

    func trackFeedbackOpened() {
        PostHogSDK.shared.capture("feedback_opened")
    }
    
    func trackDiceAnimationChanged(isOn: Bool) {
          PostHogSDK.shared.capture("dice_animation_changed", properties: ["is_on": isOn])
      }
    
    func trackHomeScreenChanged(screen: String) {
        PostHogSDK.shared.capture("home_screen_changed", properties: ["screen": screen])
    }

    // MARK: - Onboarding
    func trackOnboardingStarted() {
        PostHogSDK.shared.capture("onboarding_started")
    }

    func trackOnboardingCompleted() {
        PostHogSDK.shared.capture("onboarding_completed")
    }

    func trackOnboardingSkipped() {
        PostHogSDK.shared.capture("onboarding_skipped")
    }
    
    func trackNewsletterSignup(source: String) {
        PostHogSDK.shared.capture("newsletter_signup", properties: [
            "source": source
        ])
    }
    
    // MARK: - Monetization
    func trackPaywallViewed(triggerLocation: String) {
        PostHogSDK.shared.capture("paywall_viewed", properties: [
            "trigger_location": triggerLocation
        ])
    }

    func trackSubscriptionStarted(tier: String) {
        PostHogSDK.shared.capture("subscription_started", properties: [
            "tier": tier
        ])
    }

    func trackSubscriptionCancelled() {
        PostHogSDK.shared.capture("subscription_cancelled")
    }

    func trackSubscriptionRestored() {
        PostHogSDK.shared.capture("subscription_restored")
    }

    func trackProFeatureAttemptedWithoutAccess(featureName: String) {
        PostHogSDK.shared.capture("pro_feature_attempted_without_access", properties: [
            "feature_name": featureName
        ])
    }
}
