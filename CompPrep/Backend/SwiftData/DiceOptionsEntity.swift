//
//  DiceOptionsEntity.swift
//  CompPrep
//
//  Created by Maddisen Mohnsen on 11/13/25.
//

import SwiftData

@Model
class DiceOptionsEntity {
    @Attribute(.unique) var id: Int
    var diceOptions: [String]
    
    init(id: Int, diceOptions: [String]) {
        self.id = id
        self.diceOptions = diceOptions
    }
}
