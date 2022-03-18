# FSCScanner

This package contains libraries for NFC and QRCode reading please use them as described below.

Both nfc reading and qrcode scanning requires to add keys on **info.plist** file. for example:

```xml
<key>NSCameraUsageDescription</key>
    <string>ezeep Blue uses the Camera to scan QR Codes.</string>

<key>NFCReaderUsageDescription</key>
    <string>ezeep Blue uses the NFC to pick up print jobs from an enabled printer.</string>
```

### For NFC sanning:

```swift
    let nfcReader = NFCReader()

    private func readNFC(){
     nfcReader.addOnError { error in
         // put here the code to handle the error
         log.error(error.localizedDescription)
     }

     nfcReader.addOnRead { result in
         // put here the code to handle the scanned tag content
         log.debug(result)
     }

     nfcReader.beginScanning()
    }
```

Remember to keep an instance of the NFCReader object untill the scan is completed.

### For QR Code scanning:

```swift
    private func readQRCode(){
      let scanner = QRScanner(presenter: delegate)
      scanner.beginScanning({ scannedCode in
          // put here the code to handle the scanned code
          log.debug(scannedCode)
      }, { error in
          // put here the code to handle the error
          log.error(error.localizedDescription)
      })
    }
```

If you want you may also inject a QR code validator. This is the protocol

```swift
public protocol QRValidator {
    func isValid(scanResult: String) -> Bool
}
```

this is an example already implemented inside the library to validate urls.

```swift
public class URLValidator: QRValidator {

    public init() {}

    public func isValid(scanResult: String) -> Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: scanResult, options: [], range: NSRange(location: 0, length: scanResult.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == scanResult.utf16.count
        } else {
            return false
        }
    }
} 
```

To inject the validator create the istance 

```swift
    let scanner = QRScanner(qrValidator: URLValidator(), presenter: delegate)
```
