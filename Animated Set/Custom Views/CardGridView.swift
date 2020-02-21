//
//  AllCardsView.swift
//  Graphical Set
//
//  Created by Sebastian Malm on 1/29/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit

//@IBDesignable
class CardGridView: UIView {
    weak var superviewController: ViewController!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for subview in subviews {
            subview.removeFromSuperview()
        }
        superviewController.generateViewCards()
        for subview in subviews {
            let tap = UITapGestureRecognizer(target: superviewController, action: #selector(superviewController.tapCard(byHandlingGestureRecognizedBy:)))
            subview.addGestureRecognizer(tap)
        }
    }
}
