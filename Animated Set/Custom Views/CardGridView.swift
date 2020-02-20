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
    
    // Implicit unwrapping safe because property is set in controller property's didSet
    weak var viewController: ViewController!
    
    var modelCards = [ModelCard]() { didSet { setNeedsLayout() }}
    
    var selectedCards = Set<ModelCard>()
    
    // clear is used as a default value
    var borderColor: CGColor = UIColor.clear.cgColor
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for subview in subviews {
            subview.removeFromSuperview()
        }
        generateViewCards()
        for subview in subviews {
            let tap = UITapGestureRecognizer(target: viewController, action: #selector(viewController.tapCard(byHandlingGestureRecognizedBy:)))
            subview.addGestureRecognizer(tap)
        }
    }
 
    var previousGrid: Grid?
    
    private func generateViewCards() {
        var grid = Grid(layout: .aspectRatio(Constants.cardAspectRatio), frame: bounds)
        grid.cellCount = modelCards.count
        var gridTracker = 0
        for modelCard in modelCards {
            var cardFrame = CGRect(origin: bounds.origin, size: grid.cellSize)
            if previousGrid != nil {
                cardFrame = previousGrid?[gridTracker]?.inset(by: self.insetSize) ?? CGRect.zero
            }
            let card = CardView(fromModelCard: modelCard, withFrame: cardFrame)
            card.contentMode = .redraw
            addSubview(card)
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: Constants.flyInDuration,
                delay: 0,
                options: [],
                animations: { card.frame = grid[gridTracker]?.inset(by: self.insetSize) ?? CGRect.zero },
                completion: { finished in
                    if self.selectedCards.contains(modelCard) {
                        card.layer.borderWidth = Constants.cellInsetValue
                        card.layer.borderColor = self.borderColor
                    }
            })
            gridTracker += 1
        }
        previousGrid = grid
    }
}

extension CGRect {
    func inset(by size: CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
}

extension CardGridView {
    private struct Constants {
        static let cardAspectRatio: CGFloat = 0.57
        static let cellInsetValue: CGFloat = 4.0
        static let selectionBorderWidth: CGFloat = 5.0
        static let flyInDuration = 0.5
    }
    private var insetSize: CGSize {
        return CGSize(width: Constants.cellInsetValue, height: Constants.cellInsetValue)
    }
}
