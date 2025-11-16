//
//  OnboardingView.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/16/25.
//

import SwiftUI
import RevenueCatUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @State private var currentPage: Int = 0
    @Environment(\.colorScheme) var colorScheme
    @Namespace private var animation

    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "trophy.fill",
            title: "Practice Like You Play",
            subtitle: "Practice Makes Perfect",
            description: "Competition is unpredictable. Train for the chaos and show up ready for anything."
        ),
        OnboardingPage(
            icon: "dice.fill",
            title: "Competitive Programming",
            subtitle: "Practice Makes Perfect",
            description: "Roll the dice for random practice scenarios. Prepare for every possible situation before you compete."
        ),
        OnboardingPage(
            icon: "timer",
            title: "Smart Rest Timer",
            subtitle: "Train Like a Pro",
            description: "Random rest intervals between sets mirror the unpredictability of competition day."
        )
    ]

    var body: some View {
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

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                VStack(spacing: 24) {
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            if index == currentPage {
                                Capsule()
                                    .fill(Color.blue)
                                    .frame(width: 24, height: 8)
                                    .matchedGeometryEffect(id: "indicator", in: animation)
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)

                    VStack(spacing: 12) {
                        Button {
                            if currentPage < pages.count - 1 {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    currentPage += 1
                                }
                            } else {
                                withAnimation {
                                    hasSeenOnboarding = true
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text(currentPage == pages.count - 1 ? "Get Started" : "Continue")
                                    .font(.system(size: 17, weight: .semibold))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
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
                            .cornerRadius(16)
                            .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.2),
                                Color.blue.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 180, height: 180)
                    .blur(radius: 20)

                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.8),
                                Color.blue
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .shadow(color: Color.blue.opacity(0.3), radius: 20, x: 0, y: 10)

                Image(systemName: page.icon)
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .padding(.bottom, 20)

            VStack(spacing: 12) {
                Text(page.subtitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.blue)
                    .textCase(.uppercase)
                    .tracking(1.2)

                Text(page.title)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    OnboardingView()
}
