//
//  QRCodeErrors.swift
//  
//
//  Created by Giovanni Trovato on 26/10/21.
//

import Foundation

enum QRCodeErrors: Error {
    case deviceNotSupported
    case invalidQRcodeFormat
}

extension QRCodeErrors: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidQRcodeFormat:
                return "cms_scanners_invalid_qr_code".localized
        case .deviceNotSupported:
                return "cms_scanners_scanning_not_supported".localized
        }
    }
}
