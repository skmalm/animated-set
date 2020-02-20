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
        return "[\(shape), \(quantity), \(color), \(shading), isFaceUp: \(isFaceUp)]"
    }
    
    let shape: Shape
    let quantity: Quantity
    let color: Color
    let shading: Shading
    var isFaceUp: Bool
    
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
