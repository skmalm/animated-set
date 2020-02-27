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
    
    lazy var animator = UIDynamicAnimator(referenceView: viewController.view)
    
    var dynamicAnimationFinished = true
    
    lazy var cardBehavior = DynamicCardBehavior(inAnimator: animator, withSnapPoint: CGPoint(x: viewController.discardFrameInVCContext.midX, y: viewController.discardFrameInVCContext.midY))
    
    var modelCards = [ModelCard]() { didSet {
        // TEMP; THERE MUST BE A BETTER PLACE TO SET THE DELEGATE
        animator.delegate = self
        previousModelCards = Set(oldValue)
        if !cardViewsToRemove.isEmpty {
            for cardView in cardViewsToRemove {
                bringSubviewToFront(cardView)
                dynamicAnimationFinished = false
                cardBehavior.add(cardView)
                // setNeedsLayout will be called upon animation pause
            }
        } else {
            setNeedsLayout()
        }
    }}
    
    func cardView(fromModelCard modelCard: ModelCard) -> CardView? {
        for subview in subviews {
            guard let cardView = subview as? CardView else { return nil }
            if cardView.modelCard == modelCard {
                return cardView
            }
        }
        // return nil upon failure to find cardView
        return nil
    }
    
    var previousModelCards = Set<ModelCard>()
    
    var cardViewsToRemove: [CardView] {
        let modelCardsSet = Set(modelCards)
        let symmetricDifference = modelCardsSet.symmetricDifference(previousModelCards)
        let modelCardsToRemove = symmetricDifference.filter { modelCard in
                !modelCards.contains(modelCard)
        }
        var output = [CardView]()
        guard modelCardsToRemove.count == 3 else { return output }
        for modelCard in modelCardsToRemove {
            guard let cardView = cardView(fromModelCard: modelCard) else { continue }
            output.append(cardView)
        }
        return output
    }
    
    var modelCardsToAdd: Set<ModelCard> {
        let modelCardsSet = Set(modelCards)
        let symmetricDifference = modelCardsSet.symmetricDifference(previousModelCards)
        let modelCardsToAdd = symmetricDifference.filter { modelCard in
                modelCards.contains(modelCard)
        }
        if modelCardsToAdd.count == 3 {
            return modelCardsToAdd
        } else {
            return Set<ModelCard>()
        }
    }
    
    
    var selectedCards = Set<ModelCard>()
//    var previousSelectedCards = Set<ModelCard>()
    
    // clear is used as a default value
    var borderColor: CGColor = UIColor.clear.cgColor
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // re-set snap point in case device was rotated
        cardBehavior.snapPoint = CGPoint(x: viewController.discardFrameInVCContext.midX, y: viewController.discardFrameInVCContext.midY)
        guard dynamicAnimationFinished else { return }
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
            var cardFrame = CGRect.zero
            if previousGrid == nil || modelCardsToAdd.contains(modelCard) {
                cardFrame = CGRect(origin: deckFrame.origin, size: deckFrame.size)
            } else {
                cardFrame = previousGrid?[gridTracker]?.inset(by: self.insetSize) ?? CGRect.zero
            }
            let card = CardView(withFrame: cardFrame)
            card.contentMode = .redraw
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
                card.layer.borderWidth = Constants.selectionBorderWidth
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
        static let selectionBorderWidth: CGFloat = 50.0
        static let flyInDuration: TimeInterval = 0.5
        // flyDelayIncrement controls how long new cards wait to fly in
        static let flyDelayIncrement: TimeInterval = 0.1
    }
    private var insetSize: CGSize {
        return CGSize(width: Constants.cellInsetValue, height: Constants.cellInsetValue)
    }
}

extension CardGridView: UIDynamicAnimatorDelegate {
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        cardBehavior.switchToSnap()
        DispatchQueue.main.async {
            for cardView in self.cardViewsToRemove {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.5,
                    delay: 0.0,
                    options: [],
                    animations: { cardView.frame.size = self.viewController.deckFrameInVCContext.size },
                    completion: {
                        if $0 == .end {
                            UIView.transition(
                            with: cardView,
                            duration: 0.5,
                            options: [.transitionFlipFromLeft],
                            animations: { cardView.modelCard = nil },
                            completion: { finished in
                                self.dynamicAnimationFinished = true
                                self.setNeedsLayout()
                            })
                        }
                        
                })
            }
        }
    }
}
