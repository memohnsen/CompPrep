//
//  SettingsView.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/12/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack{
            List {
                NavigationLink(destination: ContentView()) {
                    Text("Customer Center")
                }
                
                NavigationLink(destination: ContentView()) {
                    Text("Submit Feedback")
                }
                
                NavigationLink(destination: ContentView()) {
                    Text("Leave a Review")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
