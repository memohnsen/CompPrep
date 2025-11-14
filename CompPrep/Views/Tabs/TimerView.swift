//
//  TimerView.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/12/25.
//

import SwiftUI
import Combine
import ConfettiSwiftUI

struct TimerView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var settingsShown: Bool = false
    @State private var startClicked: Bool = false
    @State private var countdownOn: Bool = false
    @State private var isCountingDown: Bool = false
    @State private var hasCountdownRun: Bool = false
    
    @State private var appliedSets: Int = 5
    @State private var draftSets: Int = 5
    @State private var appliedMinRest: Int = 1
    @State private var draftMinRest: Int = 1
    @State private var appliedMaxRest: Int = 8
    @State private var draftMaxRest: Int = 8
    
    @State private var countdown: Int = 5
    @State private var countdownScale: Double = 0
    
    @State private var isTimerRunning: Bool = false
    @State private var currentSetNumber: Int = 1
    @State private var currentRestTime: Int = 180
    @State private var timer: Timer?
    @State private var restTimes: [Int] = []
    @State private var workoutCompleted: Bool = false
    @State private var confettiCannon: Int = 0
    
    var setsRemaining: Int {
        return appliedSets - currentSetNumber
    }
    
    
    func startCountdown() {
        isCountingDown = true
        countdown = 5
        startClicked = true
        animateCountdownNumber()
        hasCountdownRun = true
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
                    startTimer()
                }
            }
        }
    }
    
    func generateRestTimes() -> [Int] {
        var times: [Int] = []
        for _ in 0..<appliedSets {
            let randomMinutes = Int.random(in: appliedMinRest...appliedMaxRest)
            times.append(randomMinutes * 60)
        }
        return times
    }
    
    func startTimer() {
        if restTimes.isEmpty {
            restTimes = generateRestTimes()
            currentSetNumber = 1
            currentRestTime = restTimes[0]
            workoutCompleted = false
        }
        
        timer?.invalidate()
        isTimerRunning = true
        
        //MARK: - adjust here to make timer countdown faster to test transitions, should be 1.0 for prod
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {_ in
            currentRestTime -= 1
            
            if currentRestTime <= 0 {
                if currentSetNumber >= appliedSets {
                    workoutCompleted = true
                    confettiCannon += 1
                    isTimerRunning = false
                    timer?.invalidate()
                    timer = nil
                    startClicked = false
                } else {
                    currentSetNumber += 1
                    currentRestTime = restTimes[currentSetNumber - 1]
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
        hasCountdownRun = false
        startClicked = false
        isCountingDown = false
        workoutCompleted = false
        restTimes = []
    }
    
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
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
                        
                        Text(workoutCompleted ? "Completed!" : !restTimes.isEmpty ? formatTime(currentRestTime) : "Press Start To Begin!")
                            .font(.system(size: workoutCompleted || restTimes.isEmpty ? 50 : 100, weight: .bold, design: .rounded))
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
                    
                    VStack(spacing: 8) {
                        Text("Up Next")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.8))
                            .textCase(.uppercase)
                            .tracking(1.0)
                        
                        if setsRemaining > 0 && currentSetNumber < restTimes.count {
                            Text(formatTime(restTimes[currentSetNumber]))
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .monospacedDigit()
                        } else if workoutCompleted {
                            Text("")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        } else if !restTimes.isEmpty && setsRemaining == 0{
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
                            .disabled(!restTimes.isEmpty)
                            .foregroundStyle(!restTimes.isEmpty ? .gray : colorScheme == .light ? .black : .white)
                        
                        HStack(spacing: 16) {
                            Button {
                                if countdownOn && !hasCountdownRun {
                                    startCountdown()
                                } else if isTimerRunning {
                                    pauseTimer()
                                    startClicked = false
                                } else {
                                    startTimer()
                                    startClicked = true
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text(workoutCompleted ? "Nice Work!" : isTimerRunning ? "Pause" : restTimes.isEmpty ? "Start" : "Resume")
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
                                resetTimer()
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
            .sheet(isPresented: $settingsShown) {
                TimerSettingsView(appliedSets: $appliedSets, draftSets: $draftSets, appliedMinRest: $appliedMinRest, draftMinRest: $draftMinRest, appliedMaxRest: $appliedMaxRest, draftMaxRest: $draftMaxRest)
                    .presentationDetents([.height(300)])
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
            .onChange(of: appliedSets) {
                if isTimerRunning {
                    resetTimer()
                }
            }
            .onChange(of: appliedMinRest) {
                if isTimerRunning {
                    resetTimer()
                }
            }
            .onChange(of: appliedMaxRest) {
                if isTimerRunning {
                    resetTimer()
                }
            }
            .overlay(alignment: .top) {
                Text("Set \(currentSetNumber)/\(appliedSets)")
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
    }
}

struct TimerSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var appliedSets: Int
    @Binding var draftSets: Int
    @Binding var appliedMinRest: Int
    @Binding var draftMinRest: Int
    @Binding var appliedMaxRest: Int
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
                    appliedSets = draftSets
                    appliedMinRest = draftMinRest
                    appliedMaxRest = draftMaxRest
                    dismiss()
                }
        }
        .padding(.horizontal)
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    TimerView()
}
