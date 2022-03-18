//
//  QRViewModel.swift
//  
//
//  Created by Giovanni Trovato on 25/10/21.
//

import Foundation
import AVFoundation
import UIKit

public class QRViewModel: ObservableObject {
    
    @Published var torchIsOn: Bool = false
    @Published var showAlert: Bool = false
    
    var publishError: ((LocalizedError)->())?
    var publishData: ((String)->())?
    
    public func addOnError(handler: ((LocalizedError)->())? ){
        publishError = handler
    }
    
    public func addOnRead(handler: ((String)->())? ){
        publishData = handler
    }
    
    private var qrValidator: QRValidator
    
    public init(qrValidator: QRValidator = AlwaysValid()) {
        self.qrValidator = qrValidator
    }
    
    func onFoundQrCode(_ code: String) {
        
        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        impactHeavy.impactOccurred()
        
        if qrValidator.isValid(scanResult: code) {
            publishData?(code)
        } else {
            publishError?(QRCodeErrors.invalidQRcodeFormat)
        }
        
        publishData = nil
        publishError = nil
    }
    
}
