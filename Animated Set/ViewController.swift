//
//  ViewController.swift
//  Graphical Set
//
//  Created by Sebastian Malm on 1/29/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startNewGame()
    }

    private var game: SetGame!
    private var cheatMode = false
    
    private func startNewGame() {
        game = SetGame()
        cheatMode = false
        previousGrid = nil
        updateUI()
    }
    
    private var allCardViews: [CardView] {
        return cardGridView.subviews as! [CardView]
    }
    
    var modelCards = [ModelCard]() { didSet { cardGridView.setNeedsLayout() }}
    var selectedCards = Set<ModelCard>()
    
    var previousGrid: Grid?
        
    func generateViewCards() {
        var grid = Grid(layout: .aspectRatio(Constants.cardAspectRatio), frame: cardGridView.bounds)
        grid.cellCount = modelCards.count
        var gridTracker = 0
        for modelCard in modelCards {
            var cardFrame = CGRect(origin: CGPoint(x: 0, y: -104.5), size: deckCardView!.frame.size)
            if previousGrid != nil {
                cardFrame = previousGrid?[gridTracker]?.inset(by: self.insetSize) ?? CGRect.zero
            }
            let card = CardView(fromModelCard: modelCard, withFrame: cardFrame)
            card.contentMode = .redraw
            // "face down" cards have a huge brown border covering the card
            card.layer.borderColor = UIColor.brown.cgColor
            if modelCard.isFaceUp {
                card.layer.borderWidth = 0.0
            } else {
                card.layer.borderWidth = 100.0
            }
            cardGridView.addSubview(card)
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: Constants.flyInDuration,
                delay: 0,
                options: [],
                animations: { card.frame = grid[gridTracker]?.inset(by: self.insetSize) ?? CGRect.zero },
                completion: { finished in
                    if !modelCard.isFaceUp {
                        UIView.transition(
                            with: card,
                            duration: 0.5,
                            options: [.transitionFlipFromLeft],
                            animations: { card.layer.borderWidth = 0.0 })
                    }
            })
            if self.selectedCards.contains(modelCard) {
                card.layer.borderWidth = Constants.cellInsetValue
                card.layer.borderColor = borderColor()
            }
            gridTracker += 1
        }
        previousGrid = grid
    }
    
    @objc func tapCard(byHandlingGestureRecognizedBy recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            // force unwrapping safe because recognizers are always set on cardViews
            let tappedViewCard = recognizer.view! as! CardView
            // cardviews themselves have a modelCard set on initialization
            let tappedModelCard = tappedViewCard.modelCard!
            game.select(tappedModelCard)
            updateUI()
        }
    }
    
    // cards are identified by indices in the game.cards array
    
    private func updateUI() {
        guard game.setAvailable() || game.cardsInDeck.count >= 3 else {
            multiplierLabel.text = "Game over!"
            return
        }
        cheatButton.isEnabled = true
        deckCountLabel.text = "Deck: \(game.cardsInDeck.count)"
        multiplierLabel.text = "Multiplier: \(game.multiplier)x"
        if cheatMode { multiplierLabel.text = "Cheat Mode" }
        scoreLabel.text = cheatMode ? "Score: N/A" : "Score: \(game.score)"
        
        selectedCards = game.selectedCards
        modelCards = game.availableCards

        // manage deal button and cheat button based on game state
        if !game.setAvailable() {
            dealButton.setTitle("No Sets. Free Draw!", for: .normal)
            cheatButton.isEnabled = false
        } else if game.selectedCardsMakeASet {
            dealButton.setTitle("Replace Matched Set", for: .normal)
        } else {
            dealButton.setTitle("Deal 3 & Reduce Multiplier", for: .normal)
        }
        if game.selectedCardsMakeASet || game.cardsInDeck.count >= 3 {
            enableDealButton()
        } else { disableDealButton() }
        // if no cards left in deck, disable deal button
        if game.cardsInDeck.count < 3 { disableDealButton() }
        game.flipAllAvailableCardsFaceUp()
    }
    
    private func disableDealButton() {
        dealButton.isEnabled = false
        dealButton.alpha = 0.3
        dealButton.setTitle("Unable to Draw", for: .normal)
    }
    
    private func enableDealButton() {
        dealButton.isEnabled = true
        dealButton.alpha = 1.0
    }
    
    // return card border color dependent on selected cards
    private func borderColor() -> CGColor {
        // if three cards are selected, border color depends on match
        if game.selectedCards.count == 3 {
            if game.selectedCardsMakeASet {
                return Styles.green
            } else {
                return Styles.red
            }
        } else { // border color if less than 3 cards are selected
            return Styles.orange
        }
    }
    
    @IBAction private func pressDealButton(_ sender: UIButton) {
        game.dealThreeCards()
        updateUI()
    }
    
    @IBAction private func touchNewGameButton(_ sender: UIButton) {
        startNewGame()
    }
    
    @IBAction private func touchCheatButton(_ sender: UIButton) {
        game.cheat()
        cheatMode = true
        updateUI()
    }
    
    @IBOutlet weak var discardCardView: CardView! { didSet {
        // TEMP, will find better way of managing what cards are shown in deck and discard
        discardCardView.modelCard = ModelCard(shape: .shape2, quantity: .two, color: .color2, shading: .shading2)
        discardCardView.contentMode = .redraw
        }}
    @IBOutlet weak var deckCardView: CardView! { didSet {
        // TEMP, will find better way of managing what cards are shown in deck and discard
        deckCardView.modelCard = ModelCard(shape: .shape1, quantity: .one, color: .color1, shading: .shading1)
        deckCardView.contentMode = .redraw
        }}
    @IBOutlet private weak var cheatButton: UIButton!
    @IBOutlet private weak var multiplierLabel: UILabel!
    @IBOutlet private weak var scoreLabel: UILabel!
    @IBOutlet private weak var deckCountLabel: UILabel!
    @IBOutlet private weak var dealButton: UIButton! { didSet {
        dealButton.layer.cornerRadius = Constants.dealButtonCornerRadius }}
    @IBOutlet weak var cardGridView: CardGridView! { didSet {
        cardGridView.superviewController = self
        cardGridView.clipsToBounds = false
        }}
}

extension ViewController {
    private struct Constants {
        static let dealButtonCornerRadius: CGFloat = 12.0
        static let cardAspectRatio: CGFloat = 0.57
        static let cellInsetValue: CGFloat = 4.0
        static let selectionBorderWidth: CGFloat = 5.0
        static let flyInDuration = 0.5
    }
    private var insetSize: CGSize {
        return CGSize(width: Constants.cellInsetValue, height: Constants.cellInsetValue)
    }
}

extension CGRect {
    func inset(by size: CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
}
