//
//  Card.swift
//  Animated Set
//
//  Created by Sebastian Malm on 2/27/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import Foundation

struct Card: Hashable {
        
    var isFaceUp = false
    var isMatched = false
    var seen = false
    private let identifier: Int
 
    static private var identifierFactory = 0
    
    static private func getUniqueIdentifier() -> Int {
        identifierFactory += 1
        return identifierFactory
    }
    
    init() {
        identifier = Card.getUniqueIdentifier()
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
}
