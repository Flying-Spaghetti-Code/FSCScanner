//
//  NFCReader.swift
//
//
//  Created by Giovanni Trovato on 28/09/21.
//

import Foundation
import CoreNFC

public class NFCReader: NSObject, NFCNDEFReaderSessionDelegate {
    var detectedMessages = [NFCNDEFMessage]()
    var session: NFCNDEFReaderSession?
    var nfcMessages: NFCMessages = DefaultMessages()
    
    var publishError: ((LocalizedError)->())?
    var publishData: ((String)->())?
    
    override public init() {
        super.init()
    }
    
    public func addOnError(handler: ((LocalizedError)->())? ){
        publishError = handler
    }
    
    public func addOnRead(handler: ((String)->())? ){
        publishData = handler
    }
    
    private func readMessages() {
        var content = ""
        
        guard let message = detectedMessages.first else {
            publishError?(NFCErrors.wrongMessages)
            return
        }
        
        content = formatData(from: message)
        publishData?(content)
    }
    
    private func formatData(from message: NFCNDEFMessage) -> String{
        var result = ""
        
        for payload in message.records {
            switch payload.typeNameFormat {
            case .nfcWellKnown:
                
                if let url = payload.wellKnownTypeURIPayload() {
                    result += "\(url.absoluteString)"
                } else {
                    result += "\(payload.wellKnownTypeTextPayload().0 ?? "data not in utf8")"
                }
                
            case .absoluteURI:
                if let text = String(data: payload.payload, encoding: .utf8) {
                    result += "\(text)"
                }
            case .media:
                if let type = String(data: payload.type, encoding: .utf8) {
                    result += "\(payload.typeNameFormat.description): " + type
                }
            case .nfcExternal, .empty, .unknown, .unchanged:
                fallthrough
            @unknown default:
                    result += payload.typeNameFormat.description
            }
        }
        return result
    }
    
    
    /// - Tag: beginScanning
    public func beginScanning() {
        // clear all the previously read messages if there are any
        detectedMessages.removeAll()
        
        guard NFCNDEFReaderSession.readingAvailable else {
            publishError?(NFCErrors.scanningNotSupported)
            return
        }

        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = nfcMessages.initialMessage
        session?.begin()
    }

    // MARK: - NFCNDEFReaderSessionDelegate

    /// - Tag: processingTagData
    public func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        DispatchQueue.main.async {
            // Process detected NFCNDEFMessage objects.
            self.detectedMessages.append(contentsOf: messages)
            self.readMessages()
        }
    }

    /// - Tag: processingNDEFTag
    public func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            // Restart polling in 500ms
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = nfcMessages.multipleTagsDetected
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }
        
        // Connect to the found tag and perform NDEF message reading
        let tag = tags.first!
        session.connect(to: tag, completionHandler: { (error: Error?) in
            if nil != error {
                session.alertMessage = self.nfcMessages.unableToConnect
                session.invalidate()
                return
            }
            
            tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                if .notSupported == ndefStatus {
                    session.alertMessage = self.nfcMessages.tagNotNdefCompliant
                    session.invalidate()
                    return
                } else if nil != error {
                    session.alertMessage = self.nfcMessages.unableToQueryStatus
                    session.invalidate()
                    return
                }
                
                tag.readNDEF(completionHandler: { (message: NFCNDEFMessage?, error: Error?) in
                    var statusMessage: String
                    if nil != error || nil == message {
                        statusMessage = self.nfcMessages.failedToRead
                    } else {
                        statusMessage = self.nfcMessages.foundMessage
                        DispatchQueue.main.async {
                            // Process detected NFCNDEFMessage objects.
                            self.detectedMessages.append(message!)
                            self.readMessages()
                        }
                    }
                    
                    session.alertMessage = statusMessage
                    session.invalidate()
                })
            })
        })
    }
    
    /// - Tag: sessionBecomeActive
    public func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        
    }
    
    /// - Tag: endScanning
    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // Check the invalidation reason from the returned error.
        if let readerError = error as? NFCReaderError {
            // Show an alert when the invalidation reason is not because of a
            // successful read during a single-tag read session, or because the
            // user canceled a multiple-tag read session from the UI or
            // programmatically using the invalidate method call.
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                publishError?(NFCErrors.sessionInvalidated)
            }
        }

        // To read new tags, a new session instance is required.
        self.session = nil
    }

    // MARK: - addMessage(fromUserActivity:)

    func addMessage(fromUserActivity message: NFCNDEFMessage) {
        DispatchQueue.main.async {
            self.detectedMessages.append(message)
            self.readMessages()
        }
    }
    
}
