//
//  TimerView.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/12/25.
//

import SwiftUI
import Combine
import ConfettiSwiftUI
import RevenueCat
import RevenueCatUI

struct TimerView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var customerManager: CustomerInfoManager
    @State private var settingsShown: Bool = false
    @State private var startClicked: Bool = false
    @State private var countdownOn: Bool = false
    @State private var isCountingDown: Bool = false
    @State private var hasCountdownRun: Bool = false
    
    @State private var draftSets: Int = 5
    @State private var draftMinRest: Int = 1
    @State private var draftMaxRest: Int = 8
    
    @State private var countdown: Int = 5
    @State private var countdownScale: Double = 0
    @State private var confettiCannon: Int = 0
    
    @State private var displayPaywall: Bool = false
    
    
    func startCountdown() {
        isCountingDown = true
        countdown = 5
        startClicked = true
        animateCountdownNumber()
        hasCountdownRun = true
        AnalyticsManager.shared.trackTimerStarted(withCountdown: true, sets: timerManager.appliedSets, minRestMin: timerManager.appliedMinRest, maxRestMin: timerManager.appliedMaxRest)
    }

    func animateCountdownNumber() {
        countdownScale = 0
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            countdownScale = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.2)) {
                countdownScale = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                countdown -= 1
                
                if countdown > 0 {
                    animateCountdownNumber()
                } else {
                    isCountingDown = false
                    startClicked = true
                    timerManager.startTimer(trackAnalytics: false)
                }
            }
        }
    }
    
    var displayText: String {
        if customerManager.hasProAccess {
            if timerManager.workoutCompleted {
                return "Completed!"
            } else if !timerManager.restTimes.isEmpty {
                return timerManager.formatTime(timerManager.currentRestTime)
            } else {
                return "Press Start To Begin!"
            }
        } else {
            return "Subscribe To Access"
        }
    }
    
    var displayFontSize: CGFloat {
        if timerManager.workoutCompleted || timerManager.restTimes.isEmpty {
            return 50
        } else {
            return 100
        }
    }

    var toggleForegroundColor: Color {
        if !timerManager.restTimes.isEmpty {
            return .gray
        } else {
            return colorScheme == .light ? .black : .white
        }
    }

    var buttonText: String {
        if timerManager.workoutCompleted {
            return "Nice Work!"
        } else if timerManager.isTimerRunning {
            return "Pause"
        } else if timerManager.restTimes.isEmpty {
            return "Start"
        } else {
            return "Resume"
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color(.systemGray6).opacity(0.3)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Text("Rest Period")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                            .textCase(.uppercase)
                            .tracking(1.2)
                        
                        Text(displayText)
                            .font(.system(size: displayFontSize, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .monospacedDigit()
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .padding(.horizontal, 20)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.8),
                                Color.blue
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(24)
                    .shadow(color: Color.blue.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    UpNextView(timerManager: timerManager)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .padding(.horizontal, 20)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.6),
                                Color.blue.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: Color.blue.opacity(0.2), radius: 15, x: 0, y: 8)
                    
                    Spacer()
                    
                    VStack {
                        Toggle("5s Countdown?", isOn: $countdownOn)
                            .padding(.bottom)
                            .frame(maxWidth: 200)
                            .disabled(!timerManager.restTimes.isEmpty)
                            .foregroundStyle(toggleForegroundColor)
                        
                        HStack(spacing: 16) {
                            Button {
                                if customerManager.hasProAccess {
                                    if countdownOn && !hasCountdownRun {
                                        startCountdown()
                                    } else if timerManager.isTimerRunning {
                                        timerManager.pauseTimer()
                                        AnalyticsManager.shared.trackTimerPaused(currentSet: timerManager.currentSetNumber, secondsRemaining: timerManager.currentRestTime)
                                        startClicked = false
                                    } else {
                                        timerManager.startTimer()
                                        startClicked = true
                                    }
                                } else {
                                    displayPaywall = true
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: timerManager.isTimerRunning ? "pause.fill" : "play.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text(buttonText)
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.green.opacity(0.8),
                                            Color.green
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: Color.green.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            
                            Button {
                                AnalyticsManager.shared.trackTimerReset(currentSet: timerManager.currentSetNumber)
                                timerManager.resetTimer()
                                hasCountdownRun = false
                                startClicked = false
                                isCountingDown = false
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Reset")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.orange.opacity(0.8),
                                            Color.orange
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                        }
                        .padding(.bottom, 28)
                    }
                }
                .padding(.horizontal, 24)
            }
            .confettiCannon(trigger: $confettiCannon, num: 200, radius: 500, hapticFeedback: true)
            .navigationTitle("Rest Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button {
                        settingsShown = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.blue)
                    }
                }
            }
            .sheet(isPresented: $displayPaywall) {
                PaywallView()
                    .onPurchaseCompleted { customerInfo in
                        print("🔐 TimerView: Purchase completed!")
                        customerManager.updateFromCustomerInfo(customerInfo)
                        displayPaywall = false
                    }
                    .onRestoreCompleted { customerInfo in
                        print("🔐 TimerView: Restore completed!")
                        customerManager.updateFromCustomerInfo(customerInfo)
                        displayPaywall = false
                    }
            }
            .sheet(isPresented: $settingsShown) {
                TimerSettingsView(timerManager: timerManager, draftSets: $draftSets, draftMinRest: $draftMinRest, draftMaxRest: $draftMaxRest)
                    .presentationDetents([.height(300)])
            }
            .onChange(of: timerManager.appliedSets) {
                if timerManager.isTimerRunning {
                    timerManager.resetTimer()
                }
            }
            .onChange(of: timerManager.appliedMinRest) {
                if timerManager.isTimerRunning {
                    timerManager.resetTimer()
                }
            }
            .onChange(of: timerManager.appliedMaxRest) {
                if timerManager.isTimerRunning {
                    timerManager.resetTimer()
                }
            }
            .overlay(alignment: .top) {
                Text("Set \(timerManager.currentSetNumber)/\(timerManager.appliedSets)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.top, 8)
            }
            .overlay{
                if startClicked && isCountingDown {
                    ZStack {
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                        
                        VStack {
                            Text("\(countdown)")
                                .font(.system(size: 120, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(40)
                                .background(
                                    Circle()
                                        .fill(Color.red)
                                        .shadow(radius: 20)
                                )
                                .scaleEffect(countdownScale)
                        }
                    }
                }
            }
        }
        .onChange(of: timerManager.workoutCompleted) { _, newValue in
            if newValue {
                confettiCannon += 1
            }
        }
        .onAppear {
            AnalyticsManager.shared.trackScreenView("Timer")
        }
    }
}

struct TimerSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var timerManager: TimerManager
    @Binding var draftSets: Int
    @Binding var draftMinRest: Int
    @Binding var draftMaxRest: Int
    
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("How Many Sets?")
                Spacer()
                Picker("How Many Sets?", selection: $draftSets) {
                    ForEach(1...20, id: \.self){
                        Text("\($0) sets")
                    }
                }
                .pickerStyle(.menu)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            HStack {
                Text("Minimum Rest Time?")
                Spacer()
                Picker("Minimum Rest Time?", selection: $draftMinRest) {
                    ForEach(1...20, id: \.self){
                        Text("\($0) min")
                    }
                }
                .pickerStyle(.menu)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            HStack {
                Text("Maximum Rest Time?")
                Spacer()
                Picker("Maximum Rest Time?", selection: $draftMaxRest) {
                    ForEach(1...20, id: \.self){
                        Text("\($0) min")
                    }
                }
                .pickerStyle(.menu)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Text("Apply")
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(.blue)
                .foregroundStyle(.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .onTapGesture {
                    timerManager.appliedSets = draftSets
                    timerManager.appliedMinRest = draftMinRest
                    timerManager.appliedMaxRest = draftMaxRest
                    dismiss()
                }
        }
        .padding(.horizontal)
        .presentationDragIndicator(.visible)
    }
}

struct UpNextView: View {
    @ObservedObject var timerManager: TimerManager

    var body: some View {
        VStack(spacing: 8) {
            Text("Up Next")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white.opacity(0.8))
                .textCase(.uppercase)
                .tracking(1.0)

            if timerManager.setsRemaining > 0 && timerManager.currentSetNumber < timerManager.restTimes.count {
                Text(timerManager.formatTime(timerManager.restTimes[timerManager.currentSetNumber]))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            } else if timerManager.workoutCompleted {
                Text("")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            } else if !timerManager.restTimes.isEmpty && timerManager.setsRemaining == 0 {
                Text("Done!")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            } else {
                Text("Click the gear icon to adjust your workout")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    TimerView()
        .environmentObject(TimerManager())
        .environmentObject(CustomerInfoManager())
}

