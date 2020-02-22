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
        // slight delay for starting game allows setup to finish before animations start
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.startNewGame()
        }
    }

    // if user rotates device, make sure grid has updated (flipped up) available cards
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if game != nil { cardGridView.modelCards = game!.availableCards }
    }
    
    var deckFrameInVCContext: CGRect {
        return view.convert(deckView.frame, from: deckView)
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
            game?.select(tappedModelCard)
            updateUI()
        }
    }
        
    private var game: SetGame?
    
    // cards are identified by indices in the game.cards array
    
    private var cheatMode = false
    
    private func startNewGame() {
        game = SetGame()
        cheatMode = false
        cardGridView.previousGrid = nil
        updateUI()
    }
    
    private var allCardViews: [CardView] {
        return cardGridView.subviews as! [CardView]
    }
    
    private func updateUI() {
        guard game != nil, game!.setAvailable() || game!.cardsInDeck.count >= 3 else {
            multiplierLabel.text = "Game over!"
            return
        }
        cheatButton.isEnabled = true
        deckCountLabel.text = "Deck: \(game!.cardsInDeck.count)"
        multiplierLabel.text = "Multiplier: \(game!.multiplier)x"
        if cheatMode { multiplierLabel.text = "Cheat Mode" }
        scoreLabel.text = cheatMode ? "Score: N/A" : "Score: \(game!.score)"
        
        cardGridView.selectedCards = game!.selectedCards
        cardGridView.modelCards = game!.availableCards

        // manage deal button and cheat button based on game state
        if !game!.setAvailable() {
            dealButton.setTitle("No Sets. Free Draw!", for: .normal)
            cheatButton.isEnabled = false
        } else if game!.selectedCardsMakeASet {
            dealButton.setTitle("Replace Matched Set", for: .normal)
        } else {
            dealButton.setTitle("Deal 3 & Reduce Multiplier", for: .normal)
        }
        if game!.selectedCardsMakeASet || game!.cardsInDeck.count >= 3 {
            enableDealButton()
        } else { disableDealButton() }
        // if no cards left in deck, disable deal button
        if game!.cardsInDeck.count < 3 { disableDealButton() }
        cardGridView.borderColor = borderColor()
        game!.flipAllAvailableCardsFaceUp()
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
        // note that force unwrapping game is safe because method is called from updateUI
        // if three cards are selected, border color depends on match
        if game!.selectedCards.count == 3 {
            if game!.selectedCardsMakeASet {
                return Styles.green
            } else {
                return Styles.red
            }
        } else { // border color if less than 3 cards are selected
            return Styles.orange
        }
    }
    
    @IBAction private func pressDealButton(_ sender: UIButton) {
        game?.dealThreeCards()
        updateUI()
    }
    
    @IBAction private func touchNewGameButton(_ sender: UIButton) {
        startNewGame()
    }
    
    @IBAction private func touchCheatButton(_ sender: UIButton) {
        game?.cheat()
        cheatMode = true
        updateUI()
    }
    
    @IBOutlet weak var deckView: UIView! { didSet {
        deckView.layer.cornerRadius = Constants.cornerRadius
        }}
    @IBOutlet weak var discardView: UIView! { didSet {
        discardView.layer.cornerRadius = Constants.cornerRadius
        }}
    
    @IBOutlet private weak var cheatButton: UIButton!
    @IBOutlet private weak var multiplierLabel: UILabel!
    @IBOutlet private weak var scoreLabel: UILabel!
    @IBOutlet private weak var deckCountLabel: UILabel!
    @IBOutlet private weak var dealButton: UIButton! { didSet {
        dealButton.layer.cornerRadius = Constants.cornerRadius }}
}

extension ViewController {
     struct Constants {
        static let cornerRadius: CGFloat = 6.0
    }
}
