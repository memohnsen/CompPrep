//
//  CompDiceView.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/12/25.
//

import SwiftUI

struct CompDiceView: View {
    @State private var settingsShown: Bool = false
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
                CompDiceSettingsView()
                    .presentationDetents([.height(275)])
            }
        }
    }
}

struct CompDiceSettingsView: View {
    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
    }
}

#Preview {
    CompDiceView()
}
