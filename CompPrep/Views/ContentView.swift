//
//  ContentView.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/12/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var selected: String = ""
    @AppStorage("selectedHomeScreen") var selectedHomeScreen = "Comp Dice"


    var body: some View {
        TabView(selection: $selected){
            Tab("Comp Dice", systemImage: "dice", value: "Comp Dice") {
                CompDiceView()
            }
            Tab("Timer", systemImage: "timer", value: "Timer") {
                TimerView()
            }
            Tab("Settings", systemImage: "gear", value: "Settings") {
                SettingsView()
            }
        }
        .onAppear{
            if selected.isEmpty {
                selected = selectedHomeScreen
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
        .modelContainer(for: DiceOptionsEntity.self, inMemory: true)
        .environmentObject(CustomerInfoManager())
        .environmentObject(TimerManager())
}
