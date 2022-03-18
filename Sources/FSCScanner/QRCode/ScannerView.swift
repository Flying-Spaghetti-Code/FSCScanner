//
//  ScannerView.swift
//  
//
//  Created by Giovanni Trovato on 26/10/21.
//

import SwiftUI

public struct ScannerView: View {
    @ObservedObject var viewModel: QRViewModel
    
    public init(_ viewModel: QRViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            
            QrCodeScannerView()
                .found(r: self.viewModel.onFoundQrCode)
                .torchLight(isOn: self.viewModel.torchIsOn)
            
            VStack {

                Spacer()
                HStack {
                    Button(action: {
                        self.viewModel.torchIsOn.toggle()
                    }, label: {
                        Image(systemName: self.viewModel.torchIsOn ? "bolt.fill" : "bolt.slash.fill")
                            .imageScale(.large)
                            .foregroundColor(self.viewModel.torchIsOn ? Color.yellow : Color.blue)
                            .padding()
                    })
                }
                .background(Color.white)
                .cornerRadius(10)
                
            }.padding()
        }
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView(QRViewModel())
    }
}
