//
//  Themes.swift
//  Animated Set
//
//  Created by Sebastian Malm on 3/2/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import Foundation

struct Themes {
    static let themes: [Int:Theme] = [
        1: Theme(name: "Halloween!", backgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), cardColor: #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1),
              emojis: ["🎃", "👻", "🦇", "😱", "😈", "🍭", "🍬", "🍎", "🙀"]),
        2: Theme(name: "Animals!", backgroundColor: #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1), cardColor: #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1),
              emojis: ["🦆", "🐌", "🦋", "🐍", "🦑", "🐆", "🐇", "🐿"]),
        3: Theme(name: "Food!", backgroundColor: #colorLiteral(red: 0.1921568662, green: 0.007843137719, blue: 0.09019608051, alpha: 1), cardColor: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1),
              emojis: ["🍉", "🥑", "🥓", "🥗", "🍣", "🍿", "🍪", "🌮"]),
        4: Theme(name: "Sports!", backgroundColor: #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1), cardColor: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1),
              emojis: ["⚽️", "🏀", "🏈", "⚾️", "🎾", "🏐", "🏉", "🎱"]),
        5: Theme(name: "People!", backgroundColor: #colorLiteral(red: 0.3176470697, green: 0.07450980693, blue: 0.02745098062, alpha: 1), cardColor: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1),
              emojis: ["👩‍🎤", "👨‍🍳", "👩‍🌾", "👮‍♂️", "🧙‍♀️", "🧟", "🤶", "🤴"]),
        6: Theme(name: "Places!", backgroundColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), cardColor: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1),
              emojis: ["🌋", "⛰", "🏝", "🏜", "🗻", "🏰", "🏯", "🏟"]),
        7: Theme(name: "Meg!", backgroundColor: #colorLiteral(red: 0.1921568662, green: 0.007843137719, blue: 0.09019608051, alpha: 1), cardColor: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1),
              emojis: ["🐈", "🐐", "💃🏻", "📚", "📝", "❄️", "🍁", "🧚‍♀️"]),
    ]
}
