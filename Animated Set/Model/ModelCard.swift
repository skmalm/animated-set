//
//  Card.swift
//  Graphical Set
//
//  Created by Sebastian Malm on 1/29/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import Foundation

struct ModelCard: Hashable, CustomStringConvertible {

    var description: String {
        return "[\(shape), \(quantity), \(color), \(shading)]"
    }
    
    static func == (lhs: ModelCard, rhs: ModelCard) -> Bool {
        return
            lhs.shape == rhs.shape &&
            lhs.quantity == rhs.quantity &&
            lhs.color == rhs.color &&
            lhs.shading == rhs.shading
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(shape)
        hasher.combine(quantity)
        hasher.combine(color)
        hasher.combine(shading)
    }
    
    let shape: Shape
    let quantity: Quantity
    let color: Color
    let shading: Shading
    var isFaceUp = false
    
    enum Shape: CaseIterable {
        case shape1
        case shape2
        case shape3
    }

    enum Quantity: Int, CaseIterable {
        case one = 1
        case two
        case three
    }

    enum Color: CaseIterable {
        case color1
        case color2
        case color3
    }

    enum Shading: CaseIterable {
        case shading1
        case shading2
        case shading3
    }
}
