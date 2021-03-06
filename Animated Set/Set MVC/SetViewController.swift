//
//  ViewController.swift
//  Graphical Set
//
//  Created by Sebastian Malm on 1/29/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit

class SetViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // starting game async allows setup to finish before animations start
        DispatchQueue.main.async {
            self.startNewGame()
        }
    }
        
    private var game: SetGame?
        
    private var cheatMode = false
    
    private func startNewGame() {
        game = SetGame()
        cheatMode = false
        cardGridView.previousGrid = nil
        updateUI()
    }
    
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
    
    private func updateUI() {
        guard game != nil, game!.setAvailable() || game!.cardsInDeck.count >= 3 else {
            multiplierLabel.text = "Game over!"
            return
        }
        cheatButton.isEnabled = true
        deckCountLabel.text = "Deck: \(game!.cardsInDeck.count)"
        if game!.cardsInDeck.count == 0 {
            deckView.alpha = Constants.disabledElementAlpha
        }
        multiplierLabel.text = "Multiplier: \(game!.multiplier)x"
        if cheatMode { multiplierLabel.text = "Cheat Mode" }
        scoreLabel.text = cheatMode ? "Score: N/A" : "Score: \(game!.score)"
        
        cardGridView.selectedCards = game!.selectedCards
        cardGridView.availableModelCards = game!.availableCards

        // manage deal button and cheat button based on game state
        if !game!.setAvailable() {
            dealButton.setTitle("No Sets. Free Draw!", for: .normal)
            cheatButton.isEnabled = false
        } else if game!.selectedCardsMakeASet {
            if game!.cardsInDeck.count >= 3 {
                dealButton.setTitle("Replace Matched Set", for: .normal)
            } else {
                dealButton.setTitle("Remove Matched Set", for: .normal)
            }
            
        } else {
            dealButton.setTitle("Deal 3 & Reduce Multiplier", for: .normal)
        }
        if game!.selectedCardsMakeASet || game!.cardsInDeck.count >= 3 {
            enableDealButton()
        } else { disableDealButton() }
        cardGridView.borderColor = borderColor()
        game!.flipAllAvailableCardsFaceUp()
    }
    
    private func disableDealButton() {
        dealButton.isEnabled = false
        dealButton.alpha = Constants.disabledElementAlpha
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
                return SetStyles.translucentGreen
            } else {
                return SetStyles.translucentRed
            }
        } else { // border color if less than 3 cards are selected
            return SetStyles.selectionGray
        }
    }
    
    @IBAction private func pressDealButton(_ sender: UIButton) {
        deal()
    }
    
    @objc private func deal() {
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
    private var allCardViews: [CardView] {
        return cardGridView.subviews as! [CardView]
    }
    @IBOutlet private weak var cardGridView: CardGridView! { didSet {
        cardGridView.delegate = self
        }}
    @IBOutlet private weak var deckView: UIView! { didSet {
        deckView.layer.cornerRadius = SetStyles.cornerRadius
        let tap = UITapGestureRecognizer(target: self, action: #selector(deal))
        deckView.addGestureRecognizer(tap)
        }}
    @IBOutlet private weak var discardView: UIView! { didSet {
        discardView.layer.cornerRadius = SetStyles.cornerRadius
        }}
    
    @IBOutlet private weak var newGameButton: UIButton! { didSet {
        newGameButton.titleLabel?.adjustsFontSizeToFitWidth = true
        }}
    @IBOutlet private weak var cheatButton: UIButton!
    @IBOutlet private weak var multiplierLabel: UILabel!
    @IBOutlet private weak var scoreLabel: UILabel!
    @IBOutlet private weak var deckCountLabel: UILabel!
    @IBOutlet private weak var dealButton: UIButton! { didSet {
        dealButton.layer.cornerRadius = SetStyles.cornerRadius
        dealButton.titleLabel?.adjustsFontSizeToFitWidth = true
        }}
    @IBOutlet weak var deckDiscardContainer: UIView!
    
    // if user rotates device, make sure grid has updated (flipped up) available cards
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if game != nil { cardGridView.availableModelCards = game!.availableCards }
    }
}

extension SetViewController: CardGridViewDelegate {
    var contextVCForDelegate: SetViewController { self }
    
    var contextViewForDelegate: UIView { view }
    
    var deckFrameInVCContext: CGRect { return view.convert(deckView.frame, from: deckView) }
    // I'm using the deck frame to calculate this due to IB bug where discardFrame is incorrect
    var discardFrameInVCContext: CGRect {
        if let deckDiscardDistance = deckDiscardContainer.constraintConstantWithIdentifier("deckDiscardDistance") {
            return CGRect(x: deckFrameInVCContext.maxX + deckDiscardDistance, y: deckFrameInVCContext.minY, width: deckFrameInVCContext.width, height: deckFrameInVCContext.height)
        } else {
            return CGRect.zero
        }
    }
    func dynamicAnimationDidStart(_ cardGridView: CardGridView) {
        view.isUserInteractionEnabled = false
    }
    
    func dynamicAnimationDidFinish(_ cardGridView: CardGridView) {
        view.isUserInteractionEnabled = true
    }
    
    
}

extension SetViewController {
    struct Constants {
        static let disabledElementAlpha: CGFloat = 0.5
        static let deckFrameToDiscardFrameDistance: CGFloat = 10.0
    }
}

extension UIView {
    func constraintConstantWithIdentifier(_ identifier: String) -> CGFloat? {
        for constraint in constraints {
            if constraint.identifier == identifier {
                return constraint.constant
            }
        }
        return nil
    }
}
