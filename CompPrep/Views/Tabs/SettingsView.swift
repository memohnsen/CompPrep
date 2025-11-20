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
    @State private var isCustomerCenterPresented: Bool = false
    @State private var feedbackPresented: Bool = false
    @State private var emailListPresented: Bool = false
    
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    let homeScreenOptions: [String] = ["Comp Dice", "Timer"]
    
    

    var body: some View {
        NavigationStack{
            List {
                Button{
                    isCustomerCenterPresented = true
                    AnalyticsManager.shared.trackCustomerSupportOpened()
                } label: {
                    HStack {
                        Text("Customer Support")
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray.opacity(0.6))
                            .font(.system(size: 13))
                            .bold()
                    }
                }
                
                Button{
                    feedbackPresented = true
                    AnalyticsManager.shared.trackFeedbackOpened()
                } label: {
                    HStack {
                        Text("Submit Feedback")
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray.opacity(0.6))
                            .font(.system(size: 13))
                            .bold()
                    }
                }
                
                Button {
                    emailListPresented = true
                } label: {
                    HStack {
                        Text("Sign Up To Recieve Updates")
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray.opacity(0.6))
                            .font(.system(size: 13))
                            .bold()
                    }
                }

//                Link(destination: URL(string: "FILL IN LATER")!) {
//                    HStack {
//                        Text("Leave A Review")
//                            .foregroundStyle(colorScheme == .light ? .black : .white)
//                        Spacer()
//                        Image(systemName: "chevron.right")
//                            .foregroundStyle(.gray.opacity(0.6))
//                            .font(.system(size: 13))
//                            .bold()
//                    }
//                }
                
                Section {
                    Toggle("Dice Animation", isOn: $diceAnimation)
                        .simultaneousGesture(TapGesture().onEnded {
                            AnalyticsManager.shared.trackDiceAnimationChanged(isOn: diceAnimation)
                        })
                    
                    Picker("Home Screen", selection: $selectedHomeScreen) {
                        ForEach(homeScreenOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    .onChange(of: selectedHomeScreen) { _, newValue in
                        AnalyticsManager.shared.trackHomeScreenChanged(screen: newValue)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $isCustomerCenterPresented) {
                CustomerCenterView()
            }
            .sheet(isPresented: $feedbackPresented) {
                FeedbackView(isPresented: $feedbackPresented)
            }
            .sheet(isPresented: $emailListPresented) {
                EmailListView(isPresented: $emailListPresented)
            }
            .overlay(alignment: .bottom) {
                Text("CompPrep Version: \(String(describing: SettingsView.appVersion!))")
                    .secondaryText()
                    .padding(.bottom, 40)
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
