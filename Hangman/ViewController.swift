//
//  ViewController.swift
//  Hangman
//
//  Created by Mihai Leonte on 9/16/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import UIKit

let MAX_NO_LIVES = 6

class ViewController: UIViewController {
    
    var solutionLabel: UILabel!
    var riddleLabel: UILabel!
    var triesLeftLabel: UILabel!
    var triedLettersLabel: UILabel!
    var textField: UITextField!

    var challengeWords = [String]()
    var challengeRiddles = [String]()
    
    
    var maximumRetries = MAX_NO_LIVES {
        didSet {
            triesLeftLabel.text = "Tries Left: \(maximumRetries)"
            if maximumRetries == 0 {
                gameOver(withWin: false)
            }
        }
    }
    var currentLevelIndex = 0
    var tries: [Character] = [] {
        didSet {
            triedLettersLabel.text = "Tried: \(tries)"
        }
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        riddleLabel = UILabel()
        riddleLabel.translatesAutoresizingMaskIntoConstraints = false
        riddleLabel.textAlignment = .left
        riddleLabel.numberOfLines = 0
        riddleLabel.font = UIFont.systemFont(ofSize: 22)
        riddleLabel.textColor = .gray
        view.addSubview(riddleLabel)
        
        solutionLabel = UILabel()
        solutionLabel.translatesAutoresizingMaskIntoConstraints = false
        solutionLabel.textAlignment = .center
        solutionLabel.font = UIFont.systemFont(ofSize: 35)
        solutionLabel.attributedText = NSAttributedString(string: "_____", attributes:[ NSAttributedString.Key.kern: 15])
        view.addSubview(solutionLabel)
        
        triedLettersLabel = UILabel()
        triedLettersLabel.translatesAutoresizingMaskIntoConstraints = false
        triedLettersLabel.textAlignment = .left
        triedLettersLabel.textColor = .gray
        triedLettersLabel.font = UIFont.systemFont(ofSize: 18)
        triedLettersLabel.numberOfLines = 0
        triedLettersLabel.text = "Tried: "
        view.addSubview(triedLettersLabel)

        triesLeftLabel = UILabel()
        triesLeftLabel.translatesAutoresizingMaskIntoConstraints = false
        triesLeftLabel.textAlignment = .left
        triesLeftLabel.textColor = .gray
        triesLeftLabel.font = UIFont.systemFont(ofSize: 18)
        triesLeftLabel.text = "Tries Left: \(maximumRetries)"
        view.addSubview(triesLeftLabel)
        
        textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.systemFont(ofSize: 30)
        textField.placeholder = "Guess"
        textField.autocapitalizationType = .allCharacters
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        view.addSubview(textField)

        
        NSLayoutConstraint.activate([
            riddleLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
            riddleLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 10),
            riddleLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 10),
            
            solutionLabel.topAnchor.constraint(equalTo: riddleLabel.bottomAnchor, constant: 20),
            solutionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            solutionLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 10),
            solutionLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 10),
            
            textField.topAnchor.constraint(equalTo: solutionLabel.bottomAnchor, constant: 30),
            textField.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            
            triesLeftLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 30),
            triesLeftLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 10),
            triesLeftLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 10),
            
            triedLettersLabel.topAnchor.constraint(equalTo: triesLeftLabel.bottomAnchor, constant: 15),
            triedLettersLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 10),
            triedLettersLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 10)
        ])
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        
        performSelector(inBackground: #selector(loadRiddlesFromFile), with: nil)
           
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let newChar = textField.text?.last else { return }
        
        let fullWord = challengeWords[currentLevelIndex].uppercased()
        var partialSolution = solutionLabel.text ?? ""
        
        if fullWord.contains(newChar) {
            for (index, char) in fullWord.enumerated() {
                
                if char.uppercased() == newChar.uppercased() {
                    //let stringIndex = fullWord.index(fullWord.startIndex, offsetBy: index)
                    partialSolution = partialSolution.replace(newChar.uppercased(), at: index)
                }
            }
            solutionLabel.text = partialSolution
            if !partialSolution.contains("_") {
                gameOver(withWin: true)
            }
        } else {
            maximumRetries -= 1
            tries.append(newChar)
        }
    }
    
    func gameOver(withWin win: Bool) {
        var title = ""
        var message = ""
        
        switch win {
        case true:
            title = "Game Won!"
            message = "Well done!"
        case false:
            title = "Game Over!"
            message = "You have no lives left!"
        }
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.loadNewLevel()
        }))
        present(ac, animated: true)
    }
    
    @objc func loadRiddlesFromFile() {
        guard let resourceURL = Bundle.main.url(forResource: "en", withExtension: "txt") else {
            print("en.txt not found...")
            return
        }
        guard let content = try? String(contentsOf: resourceURL) else {
            print("Couldn't load content...")
            return
        }
        
        let lines = content.components(separatedBy: "\n")
        
        for line in lines {
            if line.count > 5 {
                let lineParts = line.components(separatedBy: ": ")
                challengeWords.append(lineParts[0])
                challengeRiddles.append(lineParts[1])
            }
        }
        
        performSelector(onMainThread: #selector(loadNewLevel), with: nil, waitUntilDone: false)
    }
    
    @objc func loadNewLevel() {
        maximumRetries = MAX_NO_LIVES
        tries = []
        textField.text = ""
        
        let upperBound = challengeWords.count-1
        currentLevelIndex = Int.random(in: 0...upperBound)
        riddleLabel.text = challengeRiddles[currentLevelIndex]
        
        var underscoredWord = ""
        for char in challengeWords[currentLevelIndex] {
            underscoredWord += "_"
        }
        solutionLabel.text = underscoredWord
    }

}

// MARK: - Extensions
// Limit the UITextField to letters only
extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let _ = string.rangeOfCharacter(from: CharacterSet.letters){
           return true
        }
        return false
    }
}
