//
//  QRScannerViewController.swift
//  
//
//  Created by Giovanni Trovato on 25/10/21.
//

import AVFoundation
import UIKit

struct Dimensions {
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var scannedCallback: ((Result<String, QRCodeErrors>)->())?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
        
        let backButton = UIButton()
        let image = UIImage(systemName: "chevron.backward")
        backButton.setImage(image, for: .normal)
        backButton.setTitle("Back" /*"generic_back".localized*/, for: .normal)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.tintColor = UIColor.white
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        self.view.addSubview(backButton)
        
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        backButton.layer.shadowOpacity = 0.4
        backButton.layer.shadowRadius = 2
        backButton.layer.masksToBounds = false
        backButton.layer.cornerRadius = 4.0
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 52).isActive = true
        backButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16).isActive = true
        self.view.bringSubviewToFront(backButton)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        handleRotation()
    }
    
    override func viewDidLayoutSubviews() {
        handleRotation()
    }
    
    private func handleRotation(){
        if  Dimensions.isPad,
            let previewLayer = self.previewLayer,
            let connection = previewLayer.connection {
            let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? .unknown
            
            if connection.isVideoOrientationSupported,
                let videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) {
                previewLayer.frame = self.view.bounds
                connection.videoOrientation = videoOrientation
            }
        }
    }
    
    func failed() {
        scannedCallback?(.failure(.deviceNotSupported))
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }

        dismiss(animated: true)
    }

    func found(code: String) {
        scannedCallback?(.success(code))
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @objc func didTapBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
