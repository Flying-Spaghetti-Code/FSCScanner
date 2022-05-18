//
//  CameraPreview.swift
//  
//
//  Created by Giovanni Trovato on 26/10/21.
//

import UIKit
import AVFoundation


class CameraPreview: UIView {
    
    private var label:UILabel?
    private let orientationDidChange = UIDevice.orientationDidChangeNotification
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    var session = AVCaptureSession()
    weak var delegate: QrCodeCameraDelegate?
    
    init(session: AVCaptureSession) {
        super.init(frame: .zero)
        self.session = session
        NotificationCenter.default.addObserver(self, selector: #selector(setLayer), name: orientationDidChange, object: nil)
    }
    
    deinit {
       NotificationCenter.default.removeObserver(self, name: orientationDidChange, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSimulatorView(delegate: QrCodeCameraDelegate){
        self.delegate = delegate
        self.backgroundColor = UIColor.black
        label = UILabel(frame: self.bounds)
        label?.numberOfLines = 4
        label?.text = "Click here to simulate scan"
        label?.textColor = UIColor.white
        label?.textAlignment = .center
        if let label = label {
            addSubview(label)
        }
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onClick))
        self.addGestureRecognizer(gesture)
    }
    
    @objc func onClick(){
        delegate?.onSimulateScanning()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        #if targetEnvironment(simulator)
            label?.frame = self.bounds
        #else
            setLayer()
        #endif
    }
    
    @objc func setLayer(){
        let deviceTYpe = UIDevice.current.userInterfaceIdiom
        
        switch deviceTYpe {
            case .pad: handleRotation()
            default : previewLayer?.frame = self.bounds
        }
    }
    
    private func handleRotation(){
        if let previewLayer = self.previewLayer, let connection = previewLayer.connection {
            
            let orientation = UIDevice.current.orientation
            
            if connection.isVideoOrientationSupported,
                let videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) {
                previewLayer.frame = self.bounds
                connection.videoOrientation = videoOrientation
            }
        }
    }
}
