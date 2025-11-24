//
//  TimerManager.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/20/25.
//

import Combine
import Foundation
import UIKit
import ActivityKit

class TimerManager: ObservableObject {
    @Published var isTimerRunning: Bool = false
    @Published var currentSetNumber: Int = 1
    @Published var currentRestTime: Int = 180
    @Published var restTimes: [Int] = []
    @Published var workoutCompleted: Bool = false
    @Published var appliedSets: Int = 5
    @Published var appliedMinRest: Int = 1
    @Published var appliedMaxRest: Int = 8
    
    private var backgroundTime: Date?
    private var currentActivity: Activity<CompPrepLiveActionAttributes>?
    
    init() {
        setupBackgroundHandling()
    }
    
    var timer: Timer?
    var setsRemaining: Int {
        return appliedSets - currentSetNumber
    }
    
    func generateRestTimes() -> [Int] {
        var times: [Int] = []
        for _ in 0..<appliedSets {
            let randomMinutes = Int.random(in: appliedMinRest...appliedMaxRest)
            times.append(randomMinutes * 60)
        }
        return times
    }
    
    func startTimer(trackAnalytics: Bool = true) {
        if restTimes.isEmpty {
            restTimes = generateRestTimes()
            currentSetNumber = 1
            currentRestTime = restTimes[0]
            workoutCompleted = false
        }

        timer?.invalidate()
        isTimerRunning = true
        
        startLiveActivity()

        if trackAnalytics {
            AnalyticsManager.shared.trackTimerStarted(withCountdown: false, sets: appliedSets, minRestMin: appliedMinRest, maxRestMin: appliedMaxRest)
        }

        //MARK: - adjust here to make timer countdown faster to test transitions, should be 1.0 for prod
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentRestTime -= 1
            
            self.updateLiveActivity()

            if self.currentRestTime <= 0 {
                if self.currentSetNumber >= self.appliedSets {
                    self.workoutCompleted = true
                    
                    let totalRestTime = self.restTimes.reduce(0, +)
                    BadgeManager.shared.trackWorkoutCompleted(totalRestTime: totalRestTime)
                    
                    AnalyticsManager.shared.trackTimerCompleted(totalSets: self.appliedSets)
                    self.isTimerRunning = false
                    self.timer?.invalidate()
                    self.timer = nil
                    self.endLiveActivity()
                } else {
                    self.currentSetNumber += 1
                    self.currentRestTime = self.restTimes[self.currentSetNumber - 1]
                }
            }
        }
    }
    
    func pauseTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
        currentSetNumber = 1
        workoutCompleted = false
        restTimes = []
        endLiveActivity()
    }
    
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
    
    private func setupBackgroundHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func appDidEnterBackground() {
        if isTimerRunning {
            backgroundTime = Date()
        }
    }
    
    @objc private func appWillEnterForeground() {
        guard let backgroundTime = backgroundTime, isTimerRunning else { return }
        
        let elapsed = Int(Date().timeIntervalSince(backgroundTime))
        self.backgroundTime = nil
        
        updateTimerAfterBackground(elapsed: elapsed)
    }
    
    private func updateTimerAfterBackground(elapsed: Int) {
        var remainingElapsed = elapsed
        
        currentRestTime -= remainingElapsed
        
        while currentRestTime < 0 && currentSetNumber < appliedSets {
            if currentSetNumber > appliedSets {
                workoutCompleted = true
                AnalyticsManager.shared.trackTimerCompleted(totalSets: appliedSets)
                isTimerRunning = false
                timer?.invalidate()
                timer = nil
                return
            } else {
                remainingElapsed = abs(currentRestTime)
                currentSetNumber += 1
                
                if currentSetNumber < restTimes.count {
                    currentRestTime = restTimes[currentSetNumber - 1] - remainingElapsed
                }
            }
        }
    }
    
    // MARK: - Live Activity
    
    func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled")
            return
        }
        
        endLiveActivity()
        
        let attributes = CompPrepLiveActionAttributes(totalSets: appliedSets)
        let contentState = CompPrepLiveActionAttributes.ContentState(
            currentSetNumber: currentSetNumber,
            currentRestTime: currentRestTime,
            totalRestTime: restTimes[currentSetNumber - 1],
            nextRestTime: currentSetNumber < appliedSets ? restTimes[currentSetNumber] : nil
        )
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil)
            )
            print("Live Activity started")
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }
    
    func updateLiveActivity() {
        guard let activity = currentActivity else { return }
        
        let contentState = CompPrepLiveActionAttributes.ContentState(
            currentSetNumber: currentSetNumber,
            currentRestTime: currentRestTime,
            totalRestTime: restTimes[currentSetNumber - 1],
            nextRestTime: currentSetNumber < appliedSets ? restTimes[currentSetNumber] : nil
        )
        
        Task {
            await activity.update(.init(state: contentState, staleDate: nil))
        }
    }
    
    func endLiveActivity() {
        guard let activity = currentActivity else { return }
        
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            currentActivity = nil
        }
    }
}
