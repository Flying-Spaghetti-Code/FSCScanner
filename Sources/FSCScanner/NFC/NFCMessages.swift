//
//  NFCMessages.swift
//  
//
//  Created by Giovanni Trovato on 29/09/21.
//

import Foundation

protocol NFCMessages {
    var initialMessage: String { get }
    var multipleTagsDetected: String { get }
    var unableToConnect: String { get }
    var tagNotNdefCompliant: String { get }
    var unableToQueryStatus: String { get }
    var failedToRead: String { get }
    var foundMessage: String { get }
    
}

class DefaultMessages: NFCMessages {
    var initialMessage = "cms_tag_intro_message".localized
    var multipleTagsDetected = "cms_tag_multiple_tag_detected".localized
    var unableToConnect = "cms_tag_unable_to_connect".localized
    var tagNotNdefCompliant = "cms_tag_not_compliant".localized
    var unableToQueryStatus = "cms_tag_status_not_readable".localized
    var failedToRead = "cms_tag_failed_to_read".localized
    var foundMessage = "cms_tag_read_success".localized
}
