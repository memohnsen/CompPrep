//
//  BadgeManager.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/24/25.
//

import SwiftUI

struct BadgeOptions: Hashable, Codable, Identifiable {
    var id: String { name }
    var name: String
    var icon: String
    var description: String
}

@Observable
class BadgeManager {
    static let shared = BadgeManager()
    
    static let allBadges: [BadgeOptions] = [
        BadgeOptions(name: "High Roller", icon: "dice", description: "You rolled Comp Dice 100 times!"),
        BadgeOptions(name: "5 Workouts", icon: "star", description: "You completed 5 workouts with the timer!"),
        BadgeOptions(name: "10 Workouts", icon: "trophy", description: "You completed 10 workouts with the timer!"),
        BadgeOptions(name: "25 Workouts", icon: "medal", description: "You completed 25 workouts with the timer!"),
        BadgeOptions(name: "50 Workouts", icon: "crown", description: "You completed 50 workouts with the timer!"),
        BadgeOptions(name: "100 Workouts", icon: "sparkles", description: "You completed 100 workouts with the timer!"),
        BadgeOptions(name: "Week Streak", icon: "flame", description: "You used the app for 14 days straight!"),
        BadgeOptions(name: "Month Streak", icon: "fireworks", description: "You used the app for 28 days straight!"),
        BadgeOptions(name: "Speed Demon", icon: "bolt", description: "You did a full workout with less than 2 minutes of rest!"),
        BadgeOptions(name: "First Timer", icon: "flag", description: "You completed your first workout!"),
        BadgeOptions(name: "Year Strong", icon: "calendar", description: "You completed 10 workouts!"),
        BadgeOptions(name: "Consistency", icon: "chart.line.uptrend.xyaxis", description: "You used the app for 365 days straight!")
    ]
    
    private let collectedBadgesKey = "collectedBadges"
    private let diceRollCountKey = "diceRollCount"
    private let workoutCountKey = "workoutCount"
    private let lastUsedDateKey = "lastUsedDate"
    private let streakCountKey = "streakCount"
    
    var collectedBadgeNames: Set<String> {
        didSet {
            if let data = try? JSONEncoder().encode(collectedBadgeNames) {
                UserDefaults.standard.set(data, forKey: collectedBadgesKey)
            }
        }
    }
    
    var collectedBadges: [BadgeOptions] {
        BadgeManager.allBadges.filter { collectedBadgeNames.contains($0.name) }
    }
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: collectedBadgesKey),
           let names = try? JSONDecoder().decode(Set<String>.self, from: data) {
            self.collectedBadgeNames = names
        } else {
            self.collectedBadgeNames = []
        }
    }
    
    // MARK: - Dice Roll Tracking
    var diceRollCount: Int {
        get { UserDefaults.standard.integer(forKey: diceRollCountKey) }
        set { UserDefaults.standard.set(newValue, forKey: diceRollCountKey) }
    }
    
    func trackDiceRoll() {
        diceRollCount += 1
        
        if diceRollCount >= 100 {
            awardBadgeIfNeeded(named: "High Roller")
        }
    }
    
    // MARK: - Workout Tracking
    var workoutCount: Int {
        get { UserDefaults.standard.integer(forKey: workoutCountKey) }
        set { UserDefaults.standard.set(newValue, forKey: workoutCountKey) }
    }
    
    func trackWorkoutCompleted(totalRestTime: Int) {
        workoutCount += 1
        updateStreak()
        
        if workoutCount == 1 {
            awardBadgeIfNeeded(named: "First Timer")
        }
        if workoutCount >= 5 {
            awardBadgeIfNeeded(named: "5 Workouts")
        }
        if workoutCount >= 10 {
            awardBadgeIfNeeded(named: "10 Workouts")
        }
        if workoutCount >= 25 {
            awardBadgeIfNeeded(named: "25 Workouts")
        }
        if workoutCount >= 50 {
            awardBadgeIfNeeded(named: "50 Workouts")
        }
        if workoutCount >= 100 {
            awardBadgeIfNeeded(named: "100 Workouts")
        }
        
        if totalRestTime < 120 {
            awardBadgeIfNeeded(named: "Speed Demon")
        }
        
        if workoutCount >= 10 {
            awardBadgeIfNeeded(named: "Year Strong")
        }
    }
    
    // MARK: - Streak Tracking
    var lastUsedDate: Date? {
        get { UserDefaults.standard.object(forKey: lastUsedDateKey) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: lastUsedDateKey) }
    }
    
    var streakCount: Int {
        get { UserDefaults.standard.integer(forKey: streakCountKey) }
        set { 
            UserDefaults.standard.set(newValue, forKey: streakCountKey)
            checkStreakBadges()
        }
    }
    
    func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = lastUsedDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysDifference = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysDifference == 0 {
                return
            } else if daysDifference == 1 {
                streakCount += 1
            } else {
                streakCount = 1
            }
        } else {
            streakCount = 1
        }
        
        lastUsedDate = today
        checkStreakBadges()
    }
    
    private func checkStreakBadges() {
        if streakCount >= 14 {
            awardBadgeIfNeeded(named: "Week Streak")
        }
        
        if streakCount >= 28 {
            awardBadgeIfNeeded(named: "Month Streak")
        }
        
        if streakCount >= 365 {
            awardBadgeIfNeeded(named: "Consistency")
        }
    }
    
    func awardBadge(named name: String) {
        collectedBadgeNames.insert(name)
    }
    
    func hasBadge(named name: String) -> Bool {
        collectedBadgeNames.contains(name)
    }
    
    @discardableResult
    func awardBadgeIfNeeded(named name: String) -> Bool {
        if !hasBadge(named: name) {
            awardBadge(named: name)
            return true
        }
        return false
    }
}
