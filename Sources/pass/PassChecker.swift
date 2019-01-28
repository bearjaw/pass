//
//  Checker.swift
//  haveibeenpwned
//
//  Created by Max Baumbach on 28/01/2019.
//

import Foundation
import CommonCrypto

extension Data {
    var sha1: Data {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        self.withUnsafeBytes({
            _ = CC_SHA1($0, CC_LONG(self.count), &digest)
        })
        return Data(bytes: digest)
    }
}

extension String {
    var sha1: String {
        let data = self.data(using: .utf8)!
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0, CC_LONG(data.count), &digest)
        }
        return digest
            .map { String(format: "%02hhx", $0) }
            .joined()
    }
}

final class PassChecker {
    func check(input: String, onResolve: @escaping (String, String, Int) -> Void) {
        let encoded = input.sha1
        let range = encoded.prefix(upTo: String.Index(encodedOffset: 5))
        let rest = encoded.suffix(from: String.Index(encodedOffset: 5))
            let url = URL(string: "https://api.pwnedpasswords.com/range/\(range)")!
            let request = URLRequest(url: url)
            let runLoop = CFRunLoopGetCurrent()
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: request) { [weak self] (data, response, error) in
                if let responseData = data, let weakSelf = self {
                    let decoded = weakSelf.parse(data: responseData)
                    if let compromised = weakSelf.isCompromised(decoded, rest: String(rest)) {
                        let (sha1, count) = compromised
                        onResolve("Your password is compromised",range+sha1, count)
                    }else {
                        onResolve("Your password has likely not been compromised","" , 0)
                    }
                }else {
                    onResolve("Your password has likely not been compromised", "", 0)
                }
                CFRunLoopStop(runLoop)
            }
            task.resume()
            CFRunLoopRun()
    }
    
    private func parse(data: Data) -> [String] {
        if data.isEmpty { return [] }
        if let decoded = String(data: data, encoding: .utf8)?
            .components(separatedBy: "\n") {
            return decoded
        }
        return []
    }
    
    private func isCompromised(_ value: [String], rest: String) -> (String, Int)? {
        if let hit = value.first(where: { $0.contains(rest.uppercased()) }) {
            if let keyValue = hit.components(separatedBy: "\r").first?.components(separatedBy: ":") {
                if let value = keyValue.first, let count = keyValue.last {
                    return (value, Int(count)!)
                }
            }
        }
        return nil
    }
}
