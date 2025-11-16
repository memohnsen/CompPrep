//
//  CompDiceView.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/12/25.
//

import SwiftUI
import SwiftData
import RevenueCat
import RevenueCatUI

struct CompDiceView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var diceOptionsEntities: [DiceOptionsEntity]
    @Query private var subscriptionEntities: [SubscriptionEntity]
    @AppStorage("diceAnimation") var diceAnimation: Bool = true

    @State private var settingsShown: Bool = false
    @State private var rolledText: String = "Power 60% before your next attempt"
    @State private var isRolling: Bool = false
    @State private var rotationAngle: Double = 0
    @State private var displayText: String = ""

    private var hasProAccess: Bool {
        subscriptionEntities.first?.hasProAccess ?? false
    }
    
    private var diceOptions: [String] {
        if let entity = diceOptionsEntities.first {
            return entity.diceOptions
        }
        return []
    }
    
    private func initilializeDefaultOptions() {
        if diceOptionsEntities.isEmpty {
            let defaultOptions = DiceOptionsEntity(
                id: 1,
                diceOptions: [
                    "Power 60% before your next attempt",
                    "Rest 1 minute before your next set",
                    "Go back 2 sets and work back up",
                    "Rest 8 minutes before your next set",
                    "Pull 100% before your next attempt",
                    "Face the opposite direction for your next lift"
                ]
            )
            modelContext.insert(defaultOptions)
        }
    }
    
    func rollDice() {
        if diceAnimation {
            isRolling = true
            displayText = rolledText
            rotationAngle = 0
             
            for i in 0..<8 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                    let randomIndex = Int.random(in: 0..<diceOptions.count)
                    displayText = diceOptions[randomIndex]
                }
            }
            
            withAnimation(.linear(duration: 0.8)) {
                rotationAngle = 1000
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                let randomInt = Int.random(in: 0..<diceOptions.count)
                rolledText = diceOptions[randomInt]
                displayText = rolledText
                isRolling = false
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    rotationAngle = 0
                }
            }
        } else {
            let randomInt = Int.random(in: 0..<diceOptions.count)
            rolledText = diceOptions[randomInt]
        }
    }

    var body: some View {
        NavigationStack {
            if hasProAccess {
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
                    
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "dice.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(.blue)
                                Text("\(diceOptions.count) Options")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.primary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial, in: Capsule())
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                        .padding(.top, 12)
                        
                        VStack(spacing: 12) {
                            Text(isRolling ? displayText : rolledText)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white)
                                .lineLimit(3)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 400)
                        .padding(.vertical, 50)
                        .padding(.horizontal, 24)
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
                        .cornerRadius(24)
                        .shadow(color: Color.blue.opacity(0.3), radius: 20, x: 0, y: 10)
                        .rotation3DEffect(.degrees(rotationAngle), axis: (x: 1, y: 0, z: 0))
                        .scaleEffect(isRolling ? 0.95 : 1.0)
                        
                        Button{
                            rollDice()
                            AnalyticsManager.shared.trackDiceRolled(optionCount: diceOptions.count, resultText: isRolling ? displayText : rolledText)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "dice.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Roll Dice")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.green.opacity(0.8),
                                        Color.green
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.green.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.bottom, 44)
                    }
                    .padding(.horizontal, 24)
                }
                .navigationTitle("Comp Dice")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        Button {
                            settingsShown = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .sheet(isPresented: $settingsShown) {
                    if let entity = diceOptionsEntities.first{
                        CompDiceSettingsView(entity: entity)
                    }
                }
                .onAppear{
                    initilializeDefaultOptions()
                }
                .onAppear {
                    AnalyticsManager.shared.trackScreenView("CompDice")
                }
            } else {
                PaywallView()
                    .onRestoreCompleted { customerInfo in
                        NotificationCenter.default.post(name: NSNotification.Name("RefreshSubscription"), object: nil)
                    }
                    .onPurchaseCompleted { customerInfo in
                        NotificationCenter.default.post(name: NSNotification.Name("RefreshSubscription"), object: nil)
                    }
            }
        }
    }
}

struct CompDiceSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var entity: DiceOptionsEntity
    
    func deleteItem(at offsets: IndexSet) {
        entity.diceOptions.remove(atOffsets: offsets)
        try? modelContext.save()
    }
    
    func addItem(item: String) {
        entity.diceOptions.append(item)
        try? modelContext.save()
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<entity.diceOptions.count, id: \.self) { index in
                    TextField("Edit item", text: Binding(
                        get: {
                            guard index < entity.diceOptions.count else { return "" }
                            return entity.diceOptions[index]
                        },
                        set: {
                            guard index < entity.diceOptions.count else { return }
                            entity.diceOptions[index] = $0
                            try? modelContext.save()
                        }
                    ))
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
         .modelContainer(for: DiceOptionsEntity.self, inMemory: true)
 }
