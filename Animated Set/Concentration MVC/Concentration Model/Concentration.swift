//
//  Concentration.swift
//  Animated Set
//
//  Created by Sebastian Malm on 2/27/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import Foundation

class Concentration {
    
    private var timer: Timer?
    
    private(set) var flipCount = 0
    private(set) var score = 0
    private(set) var elapsedSeconds = 0
    
    private(set) var cards = [Card]()
    
    private var indexOfOneAndOnlyFaceUpCard: Int? {
        get {
            return cards.indices.filter { cards[$0].isFaceUp }.oneAndOnly
        }
        set {
            // flip every card down except for one face up card
            for index in cards.indices {
                cards[index].isFaceUp = (newValue! == index)
            }
        }
    }
    
    func chooseCard(at index: Int) {
        assert(cards.indices.contains(index), "Concentration.chooseCard(at: \(index)): chosen card not in cards")
        guard !cards[index].isMatched else { return }
        // if one card is faceup
        if let previousPickIndex = indexOfOneAndOnlyFaceUpCard {
            // ensure a different second card is clicked
            guard index != previousPickIndex else { return }
            cards[index].isFaceUp = true
            // if match found
            if cards[previousPickIndex] == cards[index] {
                score += 2
                cards[previousPickIndex].isMatched = true
                cards[index].isMatched = true
            } else { // if mismatch
                // reduce score if card involved in mismatch was seen before
                if cards[previousPickIndex].seen { score -= 1 } else {
                    cards[previousPickIndex].seen = true
                }
                if cards[index].seen { score -= 1 } else {
                    cards[index].seen = true
                }
            }
        } else { // else zero or two cards are face up
            indexOfOneAndOnlyFaceUpCard = index
        }
        flipCount += 1
    }
    
    func startNewGame(numberOfPairsOfCards: Int) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerActions), userInfo: nil, repeats: true)
        elapsedSeconds = 0
        flipCount = 0
        score = 0
        cards.removeAll()
        indexOfOneAndOnlyFaceUpCard = nil
        for _ in 0..<numberOfPairsOfCards {
            let card = Card()
            cards.append(card)
            cards.append(card)
        }
        cards.shuffle()
    }
    
    @objc private func timerActions() {
        elapsedSeconds += 1
        if elapsedSeconds % 5 == 0 {
            score -= 1
        }
    }
    
    func won() -> Bool {
        for card in cards {
            if !card.isMatched { return false }
        }
        // if all cards matched, invalidate timer and return true
        timer?.invalidate()
        return true
    }
    
    init(numberOfPairsOfCards: Int) {
        assert(numberOfPairsOfCards > 0, "Concentration.init(numberOfPairsOfCards: \(numberOfPairsOfCards)): game cannot be initialized without at least one pair of cards")
        startNewGame(numberOfPairsOfCards: numberOfPairsOfCards)
    }
    
}

extension Collection {
    var oneAndOnly: Element? {
        return count == 1 ? first : nil
    }
}
