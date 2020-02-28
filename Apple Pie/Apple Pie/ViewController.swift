//
//  ViewController.swift
//  Apple Pie
//
//  Created by Dearest on 2020/02/29.
//  Copyright © 2020 Dearest. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var treeImageView: UIImageView!
    @IBOutlet weak var currentWordLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet var letterButtons: [UIButton]!
    
    var listOfWords = ["apple","orange","mango","watermelon","cherry","pineapple"]
    let incorrectMovesAllowed = 7
    var totalWins = 0 {
        didSet {
            newRound()
        }
    }
    var totalLosses = 0 {
        didSet {
            newRound()
        }
    }
    
    var currentGame: Game!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        newRound()
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        sender.isEnabled = false
        let letterString = sender.title(for: .normal)!
        let letter = Character(letterString.lowercased())
        print("tapped key \(letter)")
        currentGame.playerGuessed(letter: letter)
        updateGameState()
        print("remain times: \(currentGame.incorrectMovesRemaining)")
    }
    
    func updateGameState() {
        if currentGame.incorrectMovesRemaining == 0 {
            totalLosses += 1
        } else if currentGame.word == currentGame.formattedWord {
            totalWins += 1
        } else {
            updateUI()
        }
    }
    
    func newRound() {
        if !listOfWords.isEmpty {
            let newWord = listOfWords.remove(at:Int(Int(arc4random()) % listOfWords.count))
            print("current word is \(newWord)")
            currentGame = Game(word: newWord, incorrectMovesRemaining: incorrectMovesAllowed, guessedLetters: [])
            enableLetterButtons(true)
            updateUI()
        } else {
            enableLetterButtons(false)
        }
    }
    
    func enableLetterButtons(_ enable: Bool) {
        for button in letterButtons {
            button.isEnabled = enable
        }
    }
    
    func updateUI() {
        var letters = [String]()
        for letter in currentGame.formattedWord {
            letters.append(String(letter))
        }
        let wordWithSpacing = letters.joined(separator: " ")
        currentWordLabel.text = wordWithSpacing
        
        scoreLabel.text = "Wins: \(totalWins), Losses: \(totalLosses), Max wins or losses: \(incorrectMovesAllowed - 1)"
        treeImageView.image = UIImage(named: "Tree \(currentGame.incorrectMovesRemaining)")
    }

}

