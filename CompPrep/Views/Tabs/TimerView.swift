//
//  TimerView.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/12/25.
//

import SwiftUI
import Combine

struct TimerView: View {
    @State private var settingsShown: Bool = false
    @State private var startClicked: Bool = false
    @State private var sets: Int = 3
    @State private var countdown: Int = 5
    @State private var countdownScale: Double = 0
    
    func startCountdown() {
        countdown = 5
        startClicked = true
        animateCountdownNumber()
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
                    startClicked = false
                }
            }
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
                        
                        Text("2:30")
                            .font(.system(size: 100, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .monospacedDigit()
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
                        
                        Text("1:00")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .monospacedDigit()
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
                    
                    HStack(spacing: 16) {
                        Button {
                            startCountdown()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Start")
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
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 24)
            }
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
                TimerSettingsView(sets: $sets)
                    .presentationDetents([.height(250)])
            }
            .overlay(alignment: .top) {
                Text("Set 2/\(sets)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.top, 8)
            }
            .overlay{
                if startClicked {
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
    @State private var min: Int = 1
    @State private var max: Int = 8
    
    @Binding var sets: Int
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("How Many Sets?")
                Spacer()
                Picker("How Many Sets?", selection: $sets) {
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
                Picker("Minimum Rest Time?", selection: $min) {
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
                Picker("Maximum Rest Time?", selection: $max) {
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
        }
        .padding(.horizontal)
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    TimerView()
}
