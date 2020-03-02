//
//  Theme.swift
//  Animated Set
//
//  Created by Sebastian Malm on 2/27/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import Foundation

import UIKit

struct Theme {
    static var identifierTracker = 0
    let identifier: Int
    let name: String
    let backgroundColor: UIColor
    let cardColor: UIColor
    let emojis: [String]
    
    init(name: String, backgroundColor: UIColor, cardColor: UIColor, emojis: [String]) {
        self.identifier = Theme.identifierTracker
        Theme.identifierTracker += 1
        self.name = name
        self.backgroundColor = backgroundColor
        self.cardColor = cardColor
        self.emojis = emojis
    }
}
