//
//  ConcetrationViewController.swift
//  Animated Set
//
//  Created by Sebastian Malm on 2/27/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // need timers for both model and controller because model logic is time based and also view needs to update every second to show elapsed time and time-based score changes
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        game = Concentration(numberOfPairsOfCards: cardButtons.count / 2)
        startNewGame()
        // TODO: game.startNewGame(numberOfPairsOfCards:) runs twice; once upon game's initialization and then again when the controller's startNewGame() function is run. Consider fixing this for app efficiency (cards are generated, removed, then generated again)
    }

    private var game: Concentration!
    private var theme: Theme!
    
    @IBOutlet private weak var themeLabel: UILabel!
    @IBOutlet private weak var flipCountLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var scoreLabel: UILabel!
    @IBOutlet private var cardButtons: [UIButton]!
    
    @IBOutlet private weak var newGameButton: UIButton!
    @IBAction private func touchNewGameButton(_ sender: UIButton) {
        startNewGame()
    }
    
    // MARK: UI Methods
    
    private func startNewGame() {
        timer?.invalidate()
        // brief timer interval means displayed time is only 0.1s off of actual elapsed time
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerActions), userInfo: nil, repeats: true)
        timeLabel.text = "Time: 0"
        newGameButton.setTitle("New Game", for: .normal)
        emoji.removeAll()
        theme = getNewTheme()
        themeLabel.text = theme.name
        self.view.backgroundColor = theme.backgroundColor
        gameEmojis = theme.emojis
        game.startNewGame(numberOfPairsOfCards: cardButtons.count / 2)
        updateViewFromModel()
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
    
    private func getNewTheme() -> Theme {
        return themes.randomElement()!
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
    
    private let themes: [Theme] = [
        Theme(name: "Halloween!", backgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), cardColor: #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1),
              emojis: ["🎃", "👻", "🦇", "😱", "😈", "🍭", "🍬", "🍎", "🙀"]),
        Theme(name: "Animals!", backgroundColor: #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1), cardColor: #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1),
              emojis: ["🦆", "🐌", "🦋", "🐍", "🦑", "🐆", "🐇", "🐿"]),
        Theme(name: "Food!", backgroundColor: #colorLiteral(red: 0.1921568662, green: 0.007843137719, blue: 0.09019608051, alpha: 1), cardColor: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1),
              emojis: ["🍉", "🥑", "🥓", "🥗", "🍣", "🍿", "🍪", "🌮"]),
        Theme(name: "Sports!", backgroundColor: #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1), cardColor: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1),
              emojis: ["⚽️", "🏀", "🏈", "⚾️", "🎾", "🏐", "🏉", "🎱"]),
        Theme(name: "People!", backgroundColor: #colorLiteral(red: 0.3176470697, green: 0.07450980693, blue: 0.02745098062, alpha: 1), cardColor: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1),
              emojis: ["👩‍🎤", "👨‍🍳", "👩‍🌾", "👮‍♂️", "🧙‍♀️", "🧟", "🤶", "🤴"]),
        Theme(name: "Places!", backgroundColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), cardColor: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1),
              emojis: ["🌋", "⛰", "🏝", "🏜", "🗻", "🏰", "🏯", "🏟"]),
        Theme(name: "Meg!", backgroundColor: #colorLiteral(red: 0.1921568662, green: 0.007843137719, blue: 0.09019608051, alpha: 1), cardColor: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1),
              emojis: ["🐈", "🐐", "💃🏻", "📚", "📝", "❄️", "🍁", "🧚‍♀️"]),
    ]
    
}
