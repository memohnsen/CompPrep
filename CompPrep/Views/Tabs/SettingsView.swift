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
    @Environment(\.colorScheme) var colorScheme
    @State private var isCustomerCenterPresented: Bool = false
    @State private var feedbackPresented: Bool = false
    
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

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
                
                NavigationLink("Paywall Test", destination: PaywallView())
            
                
                
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
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $isCustomerCenterPresented) {
                CustomerCenterView()
            }
            .sheet(isPresented: $feedbackPresented) {
                FeedbackView(isPresented: $feedbackPresented)
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
