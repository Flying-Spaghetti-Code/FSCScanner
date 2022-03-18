//
//  NFCErrors.swift
//  
//
//  Created by Giovanni Trovato on 29/09/21.
//

import Foundation

enum NFCErrors: LocalizedError {
    case scanningNotSupported
    case sessionInvalidated
    case wrongMessages
}
