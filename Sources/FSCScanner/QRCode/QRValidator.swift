//
//  QRValidator.swift
//  
//
//  Created by Giovanni Trovato on 25/10/21.
//

import Foundation

public protocol QRValidator {
    func isValid(scanResult: String) -> Bool
}

public class AlwaysValid: QRValidator {
    
    public init() {}
    
    public func isValid(scanResult: String) -> Bool {
        return true
    }
}

public class URLValidator: QRValidator {
    
    public init() {}
    
    public func isValid(scanResult: String) -> Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: scanResult, options: [], range: NSRange(location: 0, length: scanResult.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == scanResult.utf16.count
        } else {
            return false
        }
    }
}
