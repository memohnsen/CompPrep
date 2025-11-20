//
//  LaunchScreenView.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/17/25.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Color(.blue)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 160, height: 160)
                        .blur(radius: 20)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)

                    Circle()
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)

                    // Logo icon - dice representing the app
                    // When you have a logo, replace this VStack with:
                    // Image("AppLogo")
                    //     .resizable()
                    //     .scaledToFit()
                    //     .frame(width: 80, height: 80)
                    VStack(spacing: 4) {
                        Image(systemName: "dice.fill")
                            .font(.system(size: 50, weight: .semibold))
                            .foregroundStyle(.blue)

                        Image(systemName: "timer")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.blue.opacity(0.7))
                    }
                }
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .opacity(isAnimating ? 1.0 : 0.0)

                VStack(spacing: 8) {
                    Text("CompPrep")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Train Like You Compete")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                        .tracking(1.2)
                        .textCase(.uppercase)
                }
                .opacity(isAnimating ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
