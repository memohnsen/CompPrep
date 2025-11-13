//
//  SettingsView.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/12/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("diceAnimation") var diceAnimation: Bool = true
    
    var body: some View {
        NavigationStack{
            List {
                NavigationLink(destination: ContentView()) {
                    Text("Customer Center")
                }
                
                NavigationLink(destination: FeedbackView()) {
                    Text("Submit Feedback")
                }
                
                NavigationLink(destination: ContentView()) {
                    Text("Leave a Review")
                }
                
                Section {
                    Toggle("Dice Animation", isOn: $diceAnimation)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
