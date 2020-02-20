//
//  SetGame.swift
//  Graphical Set
//
//  Created by Sebastian Malm on 1/29/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import Foundation

struct SetGame {

    // in debug mode, any three cards are a set
    private let debugMode = false
    
    private(set) var score = 0
    private(set) var multiplier = 5
    
    private(set) var cardsInDeck = [ModelCard]()
    private(set) var availableCards = [ModelCard]()
    
    private(set) var selectedCardsMakeASet = false
    private(set) var selectedCards = Set<ModelCard>()
    private var cheatSet = Set<ModelCard>()
    
    mutating func shuffleAvailableCards() {
        availableCards.shuffle()
    }
    
    // add three additional cards to the available cards
    private mutating func drawThreeAdditionalCards() {
        // after initial 12-card draw, if there's a visible match, reduce the multiplier
        if availableCards.count >= 12 && setAvailable() {
            reduceMultiplier()
        }
        for _ in 1...3 {
            let drawnCard = cardsInDeck.removeFirst()
            availableCards.append(drawnCard)
        }
    }
    
    // replace a current selected match with newly drawn cards
    mutating private func replaceMatchedCards() {
        for selectedCard in selectedCards {
            if let availableCardIndex = availableCards.firstIndex(of: selectedCard) {
                let drawnCard = cardsInDeck.removeFirst()
                availableCards[availableCardIndex] = drawnCard
            }
        }
    }
    
    mutating private func reduceMultiplier() {
        if multiplier > 1 { multiplier -= 1 }
    }
    
    mutating func select(_ card: ModelCard) {
        // if a match is currently selected and card tapped is not currently selected, replace matched cards
        if selectedCardsMakeASet && !selectedCards.contains(card) {
            dealThreeCards()
        }
        selectedCardsMakeASet = false
        // if card already selected, deselect it
        if selectedCards.contains(card) {
            selectedCards.remove(card)
        } else { // select new card
            switch selectedCards.count {
            case 0, 1:
                selectedCards.insert(card)
            case 2:
                selectedCards.insert(card)
                checkSelectedCards()
            case 3...:
                selectedCards.removeAll()
                selectedCards.insert(card)
            default:
                break
            }
        }
    }
    
    mutating func cheat() {
        guard cheatSet.count == 3 else { return }
        multiplier = 0
        score = 0
        selectedCards.removeAll()
        for card in cheatSet {
            select(card)
        }
    }
    
    // deal three cards, either replacing a match or adding more available cards
    mutating func dealThreeCards() {
        guard cardsInDeck.count >= 3 else {
            // if selected cards make a set, remove them
            if selectedCardsMakeASet {
                for card in selectedCards {
                    if let availableCardIndex = availableCards.firstIndex(of: card) {
                        availableCards.remove(at: availableCardIndex)
                    }
                }
            }
            return
        }
        if selectedCardsMakeASet {
            replaceMatchedCards()
            selectedCardsMakeASet = false
        } else { // if no current match
            drawThreeAdditionalCards()
        }
    }
    
    mutating func setAvailable() -> Bool {
        for i in 0..<availableCards.count {
            for j in 1..<availableCards.count {
                for k in 2..<availableCards.count {
                    var cardsToCheck = Set<ModelCard>()
                    let cards = [availableCards[i], availableCards[j], availableCards[k]]
                    for card in cards {
                        cardsToCheck.insert(card)
                    }
                    // the cards are all unique if the Set count is 3
                    if cardsToCheck.count == 3 {
                        if isASet(cardsToCheck: cardsToCheck) {
                            // replace any previous cheat set with the current cheat set
                            cheatSet.removeAll()
                            for card in cardsToCheck {
                                cheatSet.insert(card)
                            }
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
    
    private func isASet(cardsToCheck: Set<ModelCard>) -> Bool {
        /*
         The Set data structure consists of unique items only.
         Therefore, a feature Set with three items indicates all three items are different.
         A feature Set with one item indicates all three are the same.
         A feature Set with two items indicates that the feature disallows a correct set.
         */
        var shapes = Set<ModelCard.Shape>()
        var quantities = Set<ModelCard.Quantity>()
        var colors = Set<ModelCard.Color>()
        var shadings = Set<ModelCard.Shading>()
        for card in cardsToCheck {
            shapes.insert(card.shape)
            quantities.insert(card.quantity)
            colors.insert(card.color)
            shadings.insert(card.shading)
        }
        let featureCounts = [shapes.count, quantities.count, colors.count, shadings.count]
        // returns true if feature counts doesn't contain 2
        return !featureCounts.contains(2)
    }
    
    mutating private func checkSelectedCards() {
        if isASet(cardsToCheck: selectedCards) || debugMode {
            selectedCardsMakeASet = true
            score += multiplier
        } else { // else penalize for mismatch
            score -= 1
        }
    }
    
    init() {
        // append 1 card for each possible combination of card features
        for shape in ModelCard.Shape.allCases {
            for quantity in ModelCard.Quantity.allCases {
                for color in ModelCard.Color.allCases {
                    for shading in ModelCard.Shading.allCases {
                        let newCard = ModelCard(shape: shape, quantity: quantity, color: color, shading: shading)
                        cardsInDeck.append(newCard)
                    }
                }
            }
        }
        cardsInDeck.shuffle()
        // deal 12 cards initially
        for _ in 1...4 {
            dealThreeCards()
        }
    }

}
