 import Foundation
 guard #available(macOS 10.13, *) else {
    print("Platform not supported yet")
    exit(0)
 }
 
let explanation = """
Welcome!

This script creates a SHA1 checksum of your password and then takes the first 5
characters and asks the haveibeenpwned api to return all the checksums beginning
with those first 5 characters.
These checksums are then compared to the rest of your password's checksum to identify
a compromised password.

SHA1 generation & comparison are be done locally. Only the first 5 characters of
the checksum of your are transmitted to haveibeenpwned.

Erase your terminal client's history when you're done
"""

print(explanation)
print("Type in a password you want to check:")


func getInput() -> String? {
    let keyboard = FileHandle.standardInput
    let inputData = keyboard.availableData
    let strData = String(data: inputData, encoding: .utf8)!
    return strData.trimmingCharacters(in: CharacterSet.newlines)
}

if let input = getInput() {
    let checker = PassChecker()
    checker.check(input: input) { (message, sha1, count) in
        print("\(message). \(sha1) Hits found: \(count)")
        print("Remember to clear your terminal using 'history -c'")
        exit(0)
    }
}

