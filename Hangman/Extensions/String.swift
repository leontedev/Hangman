//
//  String.swift
//  Hangman
//
//  Created by Mihai Leonte on 9/17/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation

extension String {
    func replace(_ with: String, at index: Int) -> String {
        var modifiedString = String()
        for (i, char) in self.enumerated() {
            modifiedString += String((i == index) ? with : String(char))
        }
        return modifiedString
    }
}
