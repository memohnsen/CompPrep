//
//  OnboardingView.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/16/25.
//

import SwiftUI
import RevenueCatUI
import Supabase

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @State private var currentPage: Int = 0
    @Environment(\.colorScheme) var colorScheme
    @Namespace private var animation
    
    // Newsletter state
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var isSubscribing: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "exclamationmark.triangle.fill",
            title: "Competition Day Is Chaos",
            subtitle: "The Problem",
            description: "Unexpected rest times. Random tech stops. Pressure you can't prepare for. Most athletes train perfectly, then crumble when things aren't perfect."
        ),
        OnboardingPage(
            icon: "brain.head.profile",
            title: "Train For The Unexpected",
            subtitle: "The Solution",
            description: "CompPrep throws curveballs at you in training so nothing surprises you on the platform. Become resilient to the unexpected challenges."
        ),
        OnboardingPage(
            icon: "dice.fill",
            title: "Random Challenges, Real Growth",
            subtitle: "Comp Dice",
            description: "\"Power 60% before your next attempt.\" \"Face the opposite direction.\" Prepare for the pressure, just like competition day demands."
        ),
        OnboardingPage(
            icon: "timer",
            title: "Master Unpredictable Rest",
            subtitle: "Smart Timer",
            description: "2 minutes? 8 minutes? You won't know until it happens. Train your body to perform no matter how long you've been waiting."
        ),
        OnboardingPage(
            icon: "trophy.fill",
            title: "Show Up Ready to Win",
            subtitle: "Your Edge",
            description: "While others panic at the unexpected, you'll thrive. Because you've been training for this."
        )
    ]
    
    private var totalPages: Int {
        pages.count + 1
    }
    
    private var isOnNewsletterPage: Bool {
        currentPage == pages.count
    }

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
                    
                    NewsletterOnboardingPageView(
                        firstName: $firstName,
                        lastName: $lastName,
                        email: $email
                    )
                    .tag(pages.count)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                VStack(spacing: 24) {
                    HStack(spacing: 8) {
                        ForEach(0..<totalPages, id: \.self) { index in
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
                        if isOnNewsletterPage {
                            Button {
                                Task {
                                    await subscribeAndContinue()
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    if isSubscribing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    }
                                    Text(isSubscribing ? "Subscribing..." : "Subscribe & Continue")
                                        .font(.system(size: 17, weight: .semibold))
                                    if !isSubscribing {
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.blue.opacity(isSubscribing ? 0.5 : 0.8),
                                            Color.blue.opacity(isSubscribing ? 0.7 : 1.0)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .disabled(isSubscribing || email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            
                            Button {
                                withAnimation {
                                    hasSeenOnboarding = true
                                }
                            } label: {
                                Text("Skip for now")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }
                            .disabled(isSubscribing)
                        } else {
                            Button {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    currentPage += 1
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Text("Continue")
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
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK") {
                if alertTitle == "Success" {
                    withAnimation {
                        hasSeenOnboarding = true
                    }
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    @MainActor
    private func subscribeAndContinue() async {
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertTitle = "Error"
            alertMessage = "Please enter your email to subscribe."
            showAlert = true
            return
        }
        
        guard email.contains("@") && email.contains(".") else {
            alertTitle = "Error"
            alertMessage = "Please enter a valid email address."
            showAlert = true
            return
        }
        
        isSubscribing = true
        
        do {
            let requestBody = MailingListRequest(
                firstName: firstName.isEmpty ? nil : firstName,
                lastName: lastName.isEmpty ? nil : lastName,
                email: email
            )
            
            try await supabase.functions
                .invoke(
                    "add-to-mailing-list",
                    options: FunctionInvokeOptions(
                        body: requestBody
                    )
                )
            
            AnalyticsManager.shared.trackNewsletterSignup(source: "onboarding")
            
            alertTitle = "Success"
            alertMessage = "Welcome! You've been added to our mailing list."
            
        } catch {
            if error.localizedDescription.contains("already subscribed") {
                alertTitle = "Already Subscribed"
                alertMessage = "This email is already on our mailing list. Welcome back!"
            } else {
                alertTitle = "Error"
                alertMessage = "Something went wrong. You can always subscribe later in Settings."
                #if DEBUG
                print("Newsletter signup error: \(error)")
                #endif
            }
        }
        
        isSubscribing = false
        showAlert = true
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

struct NewsletterOnboardingPageView: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var email: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
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

                Image(systemName: "envelope.badge.fill")
                    .font(.system(size: 58, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .padding(.bottom, 10)
            
            VStack(spacing: 12) {
                Text("One More Thing")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.blue)
                    .textCase(.uppercase)
                    .tracking(1.2)

                Text("Get the Edge")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text("Stay up to date on the latest products and features from MeetCal LLC. Join over a thousand other weightlifters who refuse to leave anything to chance.")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)
            }
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    TextField("First Name", text: $firstName)
                        .textFieldStyle(OnboardingTextFieldStyle())
                    
                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(OnboardingTextFieldStyle())
                }
                
                TextField("Email Address", text: $email)
                    .textFieldStyle(OnboardingTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

struct OnboardingTextFieldStyle: TextFieldStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .light ? Color(.systemGray6) : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

#Preview {
    OnboardingView()
}
