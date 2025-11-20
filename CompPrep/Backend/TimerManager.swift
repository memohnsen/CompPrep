//
//  TimerManager.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/20/25.
//

import Combine
import Foundation
import UIKit

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

        if trackAnalytics {
            AnalyticsManager.shared.trackTimerStarted(withCountdown: false, sets: appliedSets, minRestMin: appliedMinRest, maxRestMin: appliedMaxRest)
        }

        //MARK: - adjust here to make timer countdown faster to test transitions, should be 1.0 for prod
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentRestTime -= 1

            if self.currentRestTime <= 0 {
                if self.currentSetNumber >= self.appliedSets {
                    self.workoutCompleted = true
                    AnalyticsManager.shared.trackTimerCompleted(totalSets: self.appliedSets)
                    self.isTimerRunning = false
                    self.timer?.invalidate()
                    self.timer = nil
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
}
