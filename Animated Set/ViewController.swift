//
//  ViewController.swift
//  Graphical Set
//
//  Created by Sebastian Malm on 1/29/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // TEMP method, will remove button
    @IBAction func touchFlipButton(_ sender: UIButton) {
        for subview in cardGridView.subviews {
            guard let cardView = subview as? CardView else { return }
            cardView.layer.borderColor = UIColor.brown.cgColor
            if cardView.isFaceUp {
                cardView.isFaceUp = false
                UIView.transition(
                    with: cardView,
                    duration: 0.5,
                    options: [.transitionFlipFromLeft],
                    animations: { cardView.layer.borderWidth = 100 })
            } else {
                cardView.isFaceUp = true
                UIView.transition(
                    with: cardView,
                    duration: 0.5,
                    options: [.transitionFlipFromRight],
                    animations: { cardView.layer.borderWidth = 0 })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startNewGame()
    }

    @IBOutlet weak var cardGridView: CardGridView! { didSet {
        cardGridView.viewController = self
        }}
    
    @objc func tapCard(byHandlingGestureRecognizedBy recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            // force unwrapping safe because recognizers are always set on cardViews
            let tappedViewCard = recognizer.view! as! CardView
            // cardviews themselves have a modelCard set on initialization
            let tappedModelCard = tappedViewCard.modelCard!
            game.select(tappedModelCard)
            updateViewFromModel()
        }
    }
        
    private var game: SetGame!
    
    // cards are identified by indices in the game.cards array
    
    private var cheatMode = false
    
    private func startNewGame() {
        game = SetGame()
        cheatMode = false
        updateViewFromModel()
    }
    
    private var allCardViews: [CardView] {
        return cardGridView.subviews as! [CardView]
    }
    
    private func updateViewFromModel() {
        guard game.setAvailable() || game.cardsInDeck.count >= 3 else {
            multiplierLabel.text = "Game over!"
            return
        }
        cheatButton.isEnabled = true
        deckCountLabel.text = "Deck: \(game.cardsInDeck.count)"
        multiplierLabel.text = "Multiplier: \(game.multiplier)x"
        if cheatMode { multiplierLabel.text = "Cheat Mode" }
        scoreLabel.text = cheatMode ? "Score: N/A" : "Score: \(game.score)"
        
        cardGridView.selectedCards = game.selectedCards
        cardGridView.borderColor = borderColor()
        cardGridView.modelCards = game.availableCards

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
        updateViewFromModel()
    }
    
    @IBAction private func touchNewGameButton(_ sender: UIButton) {
        startNewGame()
    }
    
    @IBAction private func touchCheatButton(_ sender: UIButton) {
        game.cheat()
        cheatMode = true
        updateViewFromModel()
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
}

extension ViewController {
    private struct Constants {
        static let dealButtonCornerRadius: CGFloat = 12.0
    }
}
