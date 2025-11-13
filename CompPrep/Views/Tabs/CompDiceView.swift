//
//  CompDiceView.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/12/25.
//

import SwiftUI

struct CompDiceView: View {
    @State private var settingsShown: Bool = false
    @State private var diceOptions: [String] = [
        "Power 60% before your next attempt",
        "Rest 1 minute before your next set",
        "Go back 2 sets and work back up",
        "Rest 8 minutes before your next set",
        "Pull 100% before your next attempt",
        "Face the opposite direction for your next lift"
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                
            }
            .navigationTitle("Comp Dice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem{
                    Button{
                        settingsShown = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $settingsShown) {
                CompDiceSettingsView(diceOptions: $diceOptions)
            }
        }
    }
}

struct CompDiceSettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var diceOptions: [String]
    
    func deleteItem(at offsets: IndexSet) {
        diceOptions.remove(atOffsets: offsets)
    }
    
    func addItem(item: String) {
        diceOptions.append(item)
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(diceOptions.indices, id: \.self) { index in
                    TextField("Edit item", text: $diceOptions[index])
                }
                .onDelete(perform: deleteItem)
            }
            .presentationDragIndicator(.visible)
            .navigationTitle("Dice Options")
            .toolbar{
                ToolbarItem(placement: .topBarTrailing){
                    Button(role: .confirm) {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
                ToolbarItem {
                    Button{
                        addItem(item: "Enter your option")
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    CompDiceView()
}
