//for i in 1...3 {
//    print(Int.random(in: 0...3))
//}
//
//print("done")

//var fullWord = "Mihai"
//let stringIndex = fullWord.index(fullWord.startIndex, offsetBy: 2)
//
//print(fullWord[stringIndex])
//
//
//fullWord[stringIndex] = "a" //error: cannot assign through subscript: subscript is get-only

extension String {
    func replace(_ with: String, at index: Int) -> String {
        var modifiedString = String()
        for (i, char) in self.enumerated() {
            modifiedString += String((i == index) ? with : String(char))
        }
        return modifiedString
    }
}

let string = "Mihai"
let dd = string.replace("a", at: 2)
print(dd)
