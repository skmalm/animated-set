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
    
    weak var delegate: CardGridViewDelegate?
    
    lazy private var animator: UIDynamicAnimator = {
        assert(delegate != nil, "Nil delegate; unable to set animator reference view")
        let animator = UIDynamicAnimator(referenceView: delegate!.contextViewForDelegate)
        animator.delegate = self
        return animator
    }()
    
    private var dynamicAnimationFinished = true
    
    lazy private var cardBehavior: DynamicCardBehavior = {
        assert(delegate != nil, "Nil delegate, cannot set dynamic card behavior")
        return DynamicCardBehavior(inAnimator: animator, withSnapPoint: CGPoint(x: delegate!.discardFrameInVCContext.midX, y: delegate!.discardFrameInVCContext.midY))
    }()
    
    var availableModelCards = [ModelCard]() { didSet {
        previousModelCards = Set(oldValue)
        if !cardViewsToRemove.isEmpty {
            for cardView in cardViewsToRemove {
                bringSubviewToFront(cardView)
                dynamicAnimationFinished = false
                cardView.layer.borderWidth = 0.0
                // BREAKS MVC
                delegate?.dynamicAnimationDidStart(self)
                cardBehavior.add(cardView)
                // setNeedsLayout will be called upon animation pause
            }
        } else {
            setNeedsLayout()
        }
    }}
    
    var selectedCards = Set<ModelCard>()
    
    // clear is used as a default value
    var borderColor: CGColor = UIColor.clear.cgColor
    
    private var previousModelCards = Set<ModelCard>()
    
    // compares previous modelCards to current modelCards and returns the cardViews to be removed
    private var cardViewsToRemove: [CardView] {
        let modelCardsSet = Set(availableModelCards)
        let symmetricDifference = modelCardsSet.symmetricDifference(previousModelCards)
        let modelCardsToRemove = symmetricDifference.filter { modelCard in
                !availableModelCards.contains(modelCard)
        }
        var output = [CardView]()
        guard modelCardsToRemove.count == 3 else { return output }
        for modelCard in modelCardsToRemove {
            guard let cardView = cardView(fromModelCard: modelCard) else { continue }
            output.append(cardView)
        }
        return output
    }
    
    // compares previous modelCards to current modelCards and returns the ones that were added
    private var modelCardsToAdd: Set<ModelCard> {
        let modelCardsSet = Set(availableModelCards)
        let symmetricDifference = modelCardsSet.symmetricDifference(previousModelCards)
        let modelCardsToAdd = symmetricDifference.filter { modelCard in
                availableModelCards.contains(modelCard)
        }
        if modelCardsToAdd.count == 3 {
            return modelCardsToAdd
        } else {
            return Set<ModelCard>()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // re-set snap point in case device was rotated
        if delegate != nil {
            cardBehavior.snapPoint = CGPoint(x: delegate!.discardFrameInVCContext.midX, y: delegate!.discardFrameInVCContext.midY)
        }
        
        guard dynamicAnimationFinished else { return }
        for subview in subviews {
            subview.removeFromSuperview()
        }
        generateViewCards()
        for subview in subviews {
            assert(delegate != nil, "Nil delegate, unable to set tap gestures")
            let tap = UITapGestureRecognizer(target: delegate!.contextVCForDelegate, action: #selector(delegate!.contextVCForDelegate.tapCard(byHandlingGestureRecognizedBy:)))
            subview.addGestureRecognizer(tap)
        }
    }
 
    var previousGrid: Grid?
    
    private func generateViewCards() {
        var grid = Grid(layout: .aspectRatio(Constants.cardAspectRatio), frame: bounds)
        grid.cellCount = availableModelCards.count
        // gridGracker tracks grid cells when looping trhough modelCards
        var gridTracker = 0
        // delayTracker increases after facedown card appears, allowing cards to be drawn one at a time
        var delayTracker = 0.0
        let deckFrame = delegate != nil ? convert(delegate!.deckFrameInVCContext, from: delegate!.contextViewForDelegate) : CGRect.zero
        for modelCard in availableModelCards {
            var cardFrame = CGRect.zero
            // if no previous grid or if card is newly added, it should initially be at deck location
            if previousGrid == nil || modelCardsToAdd.contains(modelCard) {
                cardFrame = CGRect(origin: deckFrame.origin, size: deckFrame.size)
            } else {
                // if there's  previous grid and card is not new, it should start at previous grid location
                cardFrame = previousGrid?[gridTracker]?.inset(by: self.insetSize) ?? CGRect.zero
            }
            let card = CardView(withFrame: cardFrame)
            card.contentMode = .redraw
            if modelCard.isFaceUp {
                card.modelCard = modelCard
                // views are face down if they have no modelCard yet
            } else {
                delayTracker += Constants.flyDelayIncrement
                // only delay newly flown in cards, not cards already on the grid
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
                        duration: Constants.cardFlipDuration,
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
    
    private func cardView(fromModelCard modelCard: ModelCard) -> CardView? {
        for subview in subviews {
            guard let cardView = subview as? CardView else { return nil }
            if cardView.modelCard == modelCard {
                return cardView
            }
        }
        // return nil upon failure to find cardView
        return nil
    }
}

extension CGRect {
    func inset(by size: CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
}

extension CardGridView: UIDynamicAnimatorDelegate {
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        cardBehavior.switchToSnap()
        DispatchQueue.main.async {
            for cardView in self.cardViewsToRemove {
                self.startSnap(for: cardView)
            }
        }
    }
    func startSnap(for cardView: CardView) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: Constants.resizeBeforeSnapDuration,
            delay: 0.0,
            options: [],
            animations: { cardView.frame.size = self.delegate?.deckFrameInVCContext.size ?? CGSize.zero },
            completion: {
                if $0 == .end {
                    self.flipFaceDown(cardView)
                }
        })
    }
    func flipFaceDown(_ cardView: CardView) {
        UIView.transition(
            with: cardView,
            duration: Constants.cardFlipDuration,
            options: [.transitionFlipFromLeft],
            animations: { cardView.modelCard = nil },
            completion: { finished in
                self.dynamicAnimationFinished = true
                self.delegate?.dynamicAnimationDidFinish(self)
                self.setNeedsLayout()
        })
    }
}

extension CardGridView {
    private struct Constants {
        static let cardAspectRatio: CGFloat = 0.57
        static let cellInsetValue: CGFloat = 4.0
        // selection border width arbitrarily large to cover card of any size
        static let selectionBorderWidth: CGFloat = 9999.0
        static let flyInDuration: TimeInterval = 0.5
        // flyDelayIncrement controls how long new cards wait to fly in
        static let flyDelayIncrement: TimeInterval = 0.1
        static let cardFlipDuration: TimeInterval = 0.5
        static let resizeBeforeSnapDuration: TimeInterval = 0.5
    }
    private var insetSize: CGSize {
        return CGSize(width: Constants.cellInsetValue, height: Constants.cellInsetValue)
    }
}

protocol CardGridViewDelegate: AnyObject {
    var contextVCForDelegate: SetViewController { get }
    var contextViewForDelegate: UIView { get }
    var deckFrameInVCContext: CGRect { get }
    var discardFrameInVCContext: CGRect { get }
    func dynamicAnimationDidStart(_ cardGridView: CardGridView)
    func dynamicAnimationDidFinish(_ cardGridView: CardGridView)
}
