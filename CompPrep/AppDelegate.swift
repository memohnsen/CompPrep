//
//  AppDelegate.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import UIKit
import RevenueCat
import PostHog

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        #if DEBUG
        Purchases.logLevel = .debug
        #endif
        let revenueCatKey = Bundle.main.object(forInfoDictionaryKey: "REVENUECAT_API_KEY") as! String
        Purchases.configure(withAPIKey: revenueCatKey)
        
        let POSTHOG_API_KEY = Bundle.main.object(forInfoDictionaryKey: "POSTHOG_API_KEY") as! String
        let POSTHOG_HOST = Bundle.main.object(forInfoDictionaryKey: "POSTHOG_HOST") as! String
        let config = PostHogConfig(apiKey: POSTHOG_API_KEY, host: POSTHOG_HOST)
        config.captureScreenViews = false // Disable automatic screen tracking (doesn't work with SwiftUI)
        config.debug = true
        PostHogSDK.shared.setup(config)

        return true
    }
}
