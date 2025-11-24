//
//  SettingsView.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/12/25.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct SettingsView: View {
    @AppStorage("diceAnimation") var diceAnimation: Bool = true
    @AppStorage("selectedHomeScreen") var selectedHomeScreen = "Comp Dice"
    @Environment(\.colorScheme) var colorScheme
    @State private var badgeManager = BadgeManager.shared
    @State private var isCustomerCenterPresented: Bool = false
    @State private var feedbackPresented: Bool = false
    @State private var emailListPresented: Bool = false
    @State private var badgePresented: Bool = false
    
    var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    let homeScreenOptions: [String] = ["Comp Dice", "Timer"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        VStack(alignment: .leading) {
                            Button {
                                badgePresented = true
                            } label: {
                                HStack {
                                    Text("Badges")
                                        .bold()
                                        .font(.title)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundStyle(colorScheme == .light ? .black : .white)
                            }

                            ScrollView(.horizontal) {
                                HStack {
                                    if !badgeManager.collectedBadges.isEmpty {
                                        ForEach(badgeManager.collectedBadges, id: \.self) { badge in
                                            HStack {
                                                VStack {
                                                    Image(systemName: badge.icon)
                                                        .resizable()
                                                        .frame(width: 30, height: 30)
                                                    Text(badge.name)
                                                }
                                                .frame(width: 120, height: 80)
                                                .padding()
                                                .background(.gray.opacity(0.3))
                                                .cornerRadius(12)
                                            }
                                        }
                                    }
                                    else {
                                        ForEach(0..<1, id: \.self) { badge in
                                            HStack {
                                                VStack {
                                                    Image(systemName: "figure.strengthtraining.traditional")
                                                        .resizable()
                                                        .frame(width: 30, height: 30)
                                                    Text("No Badges Claimed")
                                                }
                                                .frame(width: 150, height: 80)
                                                .padding()
                                                .background(.gray.opacity(0.3))
                                                .cornerRadius(12)
                                                .padding(.trailing, 8)
                                            }
                                        }
                                    }
                                }
                                .padding(.top)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                        .cornerRadius(32)
                        .padding(.bottom, 8)
                        
                        VStack {
                            Toggle("Dice Animation", isOn: $diceAnimation)
                                .simultaneousGesture(TapGesture().onEnded {
                                    AnalyticsManager.shared.trackDiceAnimationChanged(isOn: diceAnimation)
                                })
                                .padding(.top, -2)

                            
                            Divider()
                                .padding(.vertical, 2)
                            
                            HStack {
                                Text("Home Screen")
                                Spacer()
                                Picker("Home Screen", selection: $selectedHomeScreen) {
                                    ForEach(homeScreenOptions, id: \.self) {
                                        Text($0)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                            }
                            .onChange(of: selectedHomeScreen) { _, newValue in
                                AnalyticsManager.shared.trackHomeScreenChanged(screen: newValue)
                            }
                            .padding(.bottom, -6)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                        .cornerRadius(32)
                        .padding(.bottom, 8)
                        
                        VStack {
                            Button {
                                isCustomerCenterPresented = true
                                AnalyticsManager.shared.trackCustomerSupportOpened()
                            } label: {
                                HStack {
                                    Text("Customer Support")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundStyle(colorScheme == .light ? .black : .white)
                            }
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            Button {
                                feedbackPresented = true
                                AnalyticsManager.shared.trackFeedbackOpened()
                            } label: {
                                HStack {
                                    Text("Submit Feedback")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundStyle(colorScheme == .light ? .black : .white)
                            }
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            Button {
                                emailListPresented = true
                            } label: {
                                HStack {
                                    Text("Sign Up To Receive Updates")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundStyle(colorScheme == .light ? .black : .white)
                            }
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            Link(destination: URL(string: "https://github.com/memohnsen/CompPrep")!) {
                                HStack {
                                    Text("Open Source Code on GitHub")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundStyle(colorScheme == .light ? .black : .white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                        .cornerRadius(32)
                        
                        VStack {
                            HStack {
                                Link("Privacy Policy", destination: URL(string: "https://www.meetcal.app/compprep-privacy")!)
                                Text("•")
                                Link("Terms of Service", destination: URL(string: "https://www.meetcal.app/compprep-terms")!)
                                Text("•")
                                Link("User Agreement", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                            }
                            
                            Text("CompPrep Version: \(appVersion ?? "1.0")")
                                .secondaryText()
                                .padding(.top)
                        }
                        .font(.system(size: 14))
                        .padding(.top)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isCustomerCenterPresented) {
                CustomerCenterView()
            }
            .sheet(isPresented: $feedbackPresented) {
                FeedbackView(isPresented: $feedbackPresented)
            }
            .sheet(isPresented: $emailListPresented) {
                EmailListView(isPresented: $emailListPresented)
            }
            .sheet(isPresented: $badgePresented) {
                BadgeView()
            }
        }
        .onAppear {
            AnalyticsManager.shared.trackScreenView("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
