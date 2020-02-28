//
//  Game.swift
//  Apple Pie
//
//  Created by Dearest on 2020/02/29.
//  Copyright © 2020 Dearest. All rights reserved.
//

import Foundation

struct Game {
    var word: String
    var incorrectMovesRemaining:Int
    
    var guessedLetters: [Character]
    
    var formattedWord:String {
        var guessedWord = ""
        for letter in word {
            guessedWord += guessedLetters.contains(letter) ? "\(letter)" : "_"
        }
        return guessedWord
    }
    
    mutating func playerGuessed(letter: Character) {
        guessedLetters.append(letter)
        if !word.contains(letter) {
            incorrectMovesRemaining -= 1
        }
    }
}
