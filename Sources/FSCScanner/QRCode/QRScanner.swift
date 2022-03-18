//
//  QRScanner.swift
//  
//
//  Created by Giovanni Trovato on 28/10/21.
//

import Foundation
import UIKit
import SwiftUI
import AVKit

public class QRScanner {
    
    weak var presenter: UIViewController?
    var qrValidator: QRValidator = AlwaysValid()
    
    public init(qrValidator: QRValidator = AlwaysValid(), presenter: UIViewController?) {
        self.qrValidator = qrValidator
        self.presenter = presenter
    }
    
    public func beginScanning(qrValidator: QRValidator = AlwaysValid(), _ onRead: ((String)->())?, _ onError: ((LocalizedError)->())? ) {
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            presentCameraSettings()
        case .authorized:
            createView(onRead, onError)
        default:
            requestAccessToCamera(onRead, onError)
        }
    }
    
    private func createView(_ onRead: ((String)->())?, _ onError: ((LocalizedError)->())? ) {
        let vm = QRViewModel(qrValidator: qrValidator)
        let view = ScannerView(vm)
        let vc = UIHostingController(rootView: view)
        
        vm.addOnRead { scannedCode in
            vc.closeMe()
            onRead?(scannedCode)
        }
        
        vm.addOnError(handler: { error in
            vc.closeMe()
            onError?(error)
        })
        
        if let navigationController = presenter?.navigationController {
            navigationController.pushViewController(vc, animated: true)
            return
        }
        
        vc.modalPresentationStyle = .pageSheet
        presenter?.present(vc, animated: true)
    }
    
    private func requestAccessToCamera(_ onRead: ((String)->())?, _ onError: ((LocalizedError)->())? ) {
        AVCaptureDevice.requestAccess(for: .video) { success in
            if success {
                DispatchQueue.main.async {
                    self.createView(onRead, onError)
                }
            } else {
                NSLog("The user denied peermission to access camera QR code reading is not available")
            }
        }
    }
    
    private func presentCameraSettings() {
        let title = "cms_scanners_alert_title_cemera_denied".localized
        let message = "cms_scanners_alert_message_enable_camera".localized
        showAlertForAppSettings(title: title, message: message)
    }
    
    private func showAlertForAppSettings(title: String, message: String, mainActionLabel: String? = "cms_scanners_generic_settings".localized, action: (()->())? = {}) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "cms_scanners_generic_no".localized, style: .cancel))
        ac.addAction(UIAlertAction(title: mainActionLabel, style: .default){_ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    action?()
                })
            }
        })
        
        presenter?.present(ac, animated: true)
    }
    
}


private extension UIViewController {
    var isModal: Bool {
        if let index = navigationController?.viewControllers.firstIndex(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            return true
        } else if navigationController?.presentingViewController?.presentedViewController == navigationController {
            return true
        } else if tabBarController?.presentingViewController is UITabBarController {
            return true
        } else {
            return false
        }
    }
    
    func closeMe() {
        if isModal {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}
