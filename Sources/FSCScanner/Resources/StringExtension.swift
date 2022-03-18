//
//  StringExtension.swift
//
//
//  Created by Giovanni Trovato on 29/09/21.
//

import Foundation

extension String {
    
    var localized: String {
        
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}

extension String {
    
    func replacingVArgsWith(_ strings: String...) -> String {
        
        var result = self
        for string in strings {
            
            result = result.stringByReplacingFirstOccurrenceOfString(target: "%s", withString: string)
        }
        return result
    }
    
    func replacingVArgsWith(_ ints: Int...) -> String {
        
        var result = self
        for int in ints {
            
            result = result.stringByReplacingFirstOccurrenceOfString(target: "%s", withString: "\(int)")
        }
        return result
    }
    
    func replacingVArgsWith(_ doubles: Double...) -> String {
        
        var result = self
        for double in doubles {
            
            result = result.stringByReplacingFirstOccurrenceOfString(target: "%s", withString: "\(double)")
        }
        return result
    }
    
    
    func stringByReplacingFirstOccurrenceOfString(target: String, withString replaceString: String) -> String {
        
        if let range = self.range(of: target) {
            
            return self.replacingCharacters(in: range, with: replaceString)
        }
        return self
    }
    
    
    var lastPathComponent: String {
        get {
            return (self as NSString).lastPathComponent
        }
    }
    
    var pathExtension: String {
        get {
            return (self as NSString).pathExtension
        }
    }
    
    var stringByDeletingLastPathComponent: String {
        
        get {
            return (self as NSString).deletingLastPathComponent
        }
    }
    
    var stringByDeletingPathExtension: String {
        get {
            return (self as NSString).deletingPathExtension
        }
    }
    
    var pathComponents: [String] {
        get {
            return (self as NSString).pathComponents
        }
    }
    
    func stringByAppendingPathComponent(_ path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
    
    func stringByAppendingPathExtension(_ ext: String) -> String? {
        let nsSt = self as NSString
        return nsSt.appendingPathExtension(ext)
    }
    
    func withComponents(components: String...) -> String {
        
        var result = self
        var counter = 1
        for component in components {
            
            result = result.replacingOccurrences(of: "%\(counter)$s", with: component)
            counter += 1
        }
        return result
    }
}
