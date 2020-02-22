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
        // gridGracker tracks grid cells when looping trhough modelCards
        var gridTracker = 0
        // delayTracker increases after facedown card appears, allowing cards to be drawn one at a time
        var delayTracker = 0.0
        let deckFrame = convert(viewController.deckFrameInVCContext, from: viewController.view)
        for modelCard in modelCards {
            let cardFrame = previousGrid?[gridTracker]?.inset(by: self.insetSize) ?? CGRect(origin: deckFrame.origin, size: deckFrame.size)
            let card = CardView(withFrame: cardFrame)
            card.contentMode = .redraw
            // "face down" cards have a huge brown border covering the card
            card.layer.borderColor = UIColor.brown.cgColor
            if modelCard.isFaceUp {
                card.modelCard = modelCard
            } else {
                delayTracker += Constants.flyDelayIncrement
            }
            addSubview(card)
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: Constants.flyInDuration,
                delay: delayTracker,
                options: [],
                animations: { card.frame = grid[gridTracker]?.inset(by: self.insetSize) ?? CGRect.zero },
                completion: { finished in
                    if !modelCard.isFaceUp {
                        UIView.transition(
                        with: card,
                        duration: 0.5,
                        options: [.transitionFlipFromLeft],
                        animations: { card.modelCard = modelCard })
                    }
            })
            if self.selectedCards.contains(modelCard) {
                card.layer.borderWidth = Constants.cellInsetValue
                card.layer.borderColor = self.borderColor
            }
            gridTracker += 1
        }
        previousGrid = grid
        delayTracker = 0.0
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
        static let flyInDuration: TimeInterval = 0.5
        // flyDelayIncrement controls how long new cards wait to fly in
        static let flyDelayIncrement: TimeInterval = 0.1
    }
    private var insetSize: CGSize {
        return CGSize(width: Constants.cellInsetValue, height: Constants.cellInsetValue)
    }
}
