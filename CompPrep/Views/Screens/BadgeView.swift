//
//  BadgeView.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/24/25.
//

import SwiftUI

struct BadgeView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var badgeManager = BadgeManager.shared
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    func badgeCollectedBGColor(badge: BadgeOptions) -> Color {
        if badgeManager.hasBadge(named: badge.name) {
            return .gray.opacity(0.3)
        } else {
            return .gray.opacity(0.1)
        }
    }
    
    func badgeCollectedFGColor(badge: BadgeOptions) -> Color {
        if badgeManager.hasBadge(named: badge.name) {
            if colorScheme == .light {
                return .black
            } else {
                return .white
            }
        } else {
            return .gray.opacity(0.8)
        }
    }
    
    var badgesSorted: [BadgeOptions] {
        BadgeManager.allBadges.sorted { item1, item2 in
            badgeManager.hasBadge(named: item1.name) && !badgeManager.hasBadge(named: item2.name)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(badgesSorted, id: \.self) { badge in
                        VStack {
                            Image(systemName: badge.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                            Text(badge.name)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 4)
                            Text(badge.description)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(badgeCollectedBGColor(badge: badge))
                        .foregroundStyle(badgeCollectedFGColor(badge: badge))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Badges")
        }
    }
}

#Preview {
    BadgeView()
}
