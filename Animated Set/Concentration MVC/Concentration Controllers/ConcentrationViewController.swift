//
//  ConcetrationViewController.swift
//  Animated Set
//
//  Created by Sebastian Malm on 2/27/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit

class ConcentrationViewController: UIViewController {

    // need timers for both model and controller because model logic is time based and also view needs to update every second to show elapsed time and time-based score changes
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        game = Concentration(numberOfPairsOfCards: cardButtons.count / 2)
        startNewGame()
        // TODO: game.startNewGame(numberOfPairsOfCards:) runs twice; once upon game's initialization and then again when the controller's startNewGame() function is run. Consider fixing this for app efficiency (cards are generated, removed, then generated again)
    }

    private var game: Concentration!
    // Currently using theme 1 as default theme
    var theme = Themes.themes[1]! { didSet { setTheme(); updateViewFromModel() }}
    
    @IBOutlet private weak var themeLabel: UILabel! { didSet { themeLabel.text = theme.name }}
    @IBOutlet private weak var flipCountLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var scoreLabel: UILabel!
    @IBOutlet private var cardButtons: [UIButton]!
    
    @IBOutlet private weak var newGameButton: UIButton!
    @IBAction private func touchNewGameButton(_ sender: UIButton) {
        startNewGame()
    }
        
    private func startNewGame() {
        timer?.invalidate()
        // brief timer interval means displayed time is only 0.1s off of actual elapsed time
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerActions), userInfo: nil, repeats: true)
        timeLabel.text = "Time: 0"
        newGameButton.setTitle("New Game", for: .normal)
        game.startNewGame(numberOfPairsOfCards: cardButtons.count / 2)
        setTheme()
        updateViewFromModel()
    }
    
    private func setTheme() {
        emoji.removeAll()
        view.backgroundColor = theme.backgroundColor
        gameEmojis = theme.emojis
    }
    
    @objc private func timerActions() {
        timeLabel.text = "Time: \(game.elapsedSeconds)"
        scoreLabel.text = "Score: \(game.score)"
    }
    
    @IBAction private func touchCard(_ sender: UIButton) {
        guard let viewCardIndex = cardButtons.firstIndex(of: sender) else { return }
        game.chooseCard(at: viewCardIndex)
        updateViewFromModel()
    }
    
    private var emoji = [Card: String]()
    private var gameEmojis: [String]!
    
    private func emoji(forCard card: Card) -> String {
        if !emoji.keys.contains(card) {
            guard gameEmojis.count > 0 else { return "?" }
            emoji[card] = gameEmojis.remove(at: Int.random(in: 0..<gameEmojis.count))
        }
        return emoji[card]!
    }
    
    private func updateViewFromModel() {
        flipCountLabel.text = "Flips: \(game.flipCount)"
        scoreLabel.text = "Score: \(game.score)"
        for index in cardButtons.indices {
            let viewCard = cardButtons[index]
            let modelCard = game.cards[index]
            if modelCard.isFaceUp {
                viewCard.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                // ensure that there are enough emoji choices before setting emoji
                let emojiToUse = emoji(forCard: modelCard)
                viewCard.setTitle(emojiToUse, for: .normal)
            } else {
                viewCard.backgroundColor = !modelCard.isMatched ? theme.cardColor : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
                viewCard.setTitle("", for: .normal)
            }
        }
        if game.won() {
            newGameButton.setTitle("You win! Play again?", for: .normal)
            timer?.invalidate()
        }
    }
    
}
