# NFCReaderWriter
<img src="https://github.com/janlionly/NFCReaderWriter/blob/master/Resources/NFC-Result.PNG" width="250" height="541">

[![Version](https://img.shields.io/cocoapods/v/NFCReaderWriter.svg?style=flat)](https://cocoapods.org/pods/NFCReaderWriter)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/NFCReaderWriter.svg?style=flat)](https://github.com/janlionly/NFCReaderWriter/blob/master/LICENSE)
[![Platform](https://img.shields.io/cocoapods/p/NFCReaderWriter.svg?style=flat)](https://github.com/janlionly/NFCReaderWriter)
![Swift](https://img.shields.io/badge/%20in-swift%204.2-orange.svg)

## Description
**NFCReaderWriter** which supports to read data from NFC chips(iOS 11), write data to NFC chips(iOS 13) and read NFC tags infos(iOS 13) by iOS devices. Compatible with both Swift and Objective-C.

## Installation
### CocoaPods
```swift
pod 'NFCReaderWriter'
```

### Carthage
```swift
github "janlionly/NFCReaderWriter"
```

### Swift Package Manager
- iOS: Open Xcode, File->Swift Packages, search input **https://github.com/janlionly/NFCReaderWriter.git**, and then select Version Up to Next Major **1.1.4** < .
- Or add dependencies in your `Package.swift`:
```swift
.package(url: "https://github.com/janlionly/NFCReaderWriter.git", .upToNextMajor(from: "1.1.4")),
```

## Usage
1. Set your provisioning profile to support for **Near Field Communication Tag Reading**;

2. Open your project target, on **Signing & Capabilities** tab, add the Capability of **Near Field Communication Tag Reading**;

3. Remember to add **NFCReaderUsageDescription** key for descriptions to your Info.plist.

4. Support for read tag identifier(iOS 13), you should add your NFC tag type descriptions to your Info.plist. 

   (eg: like **com.apple.developer.nfc.readersession.felica.systemcodes**, **com.apple.developer.nfc.readersession.iso7816.select-identifiers**)

**More information please run demo above.**

```swift
// Updated: add alertMessage property when detected NFC successfully 
readerWriter.detectedMessage = "Your Read/Write NFC successful content."

// Or you can change alertMessage anywhere before call 'readerWriter.end()' as follow:
readerWriter.alertMessage = "NFC Tag Info detected"

/// ----------------------
/// 1. NFC Reader(iOS 11):
/// ----------------------
// every time read NFC chip's data, open a new session to detect
readerWriter.newReaderSession(with: self, invalidateAfterFirstRead: true, alertMessage: "Nearby NFC Card for read")
readerWriter.begin()

// implement NFCReaderDelegate to read NFC chip's data
func reader(_ session: NFCReader, didDetectNDEFs messages: [NFCNDEFMessage]) {
  for message in messages {
    for (i, record) in message.records.enumerated() {
      print("Record \(i+1): \(String(data: record.payload, encoding: .ascii))")
      // other record properties: typeNameFormat, type, identifier
    }
  }
  readerWriter.end()
}

/// ----------------------
/// 2. NFC Writer(iOS 13):
/// ----------------------
// every time write data to NFC chip, open a new session to write
readerWriter.newWriterSession(with: self, isLegacy: true, invalidateAfterFirstRead: true, alertMessage: "Nearby NFC Card for write")
readerWriter.begin()

// implement NFCReaderDelegate to write data to NFC chip
func reader(_ session: NFCReader, didDetect tags: [NFCNDEFTag]) {
	  // here for write test data
    var payloadData = Data([0x02])
    let urls = ["apple.com", "google.com", "facebook.com"]
    payloadData.append(urls[Int.random(in: 0..<urls.count)].data(using: .utf8)!)

    let payload = NFCNDEFPayload.init(
      format: NFCTypeNameFormat.nfcWellKnown,
      type: "U".data(using: .utf8)!,
      identifier: Data.init(count: 0),
      payload: payloadData,
      chunkSize: 0)

    let message = NFCNDEFMessage(records: [payload])

    readerWriter.write(message, to: tags.first!) { (error) in
        if let err = error {
            print("ERR:\(err)")
        } else {
            print("write success")
        }
        self.readerWriter.end()
     }
}

/// -------------------------
/// 3. NFC Tag Reader(iOS 13)
/// -------------------------
readerWriter.newWriterSession(with: self, isLegacy: false, invalidateAfterFirstRead: true, alertMessage: "Nearby NFC card for read tag identifier")
readerWriter.begin()

// implement NFCReaderDelegate to read tag info from NFC chip
func reader(_ session: NFCReader, didDetect tag: __NFCTag, didDetectNDEF message: NFCNDEFMessage) {
    let tagId = readerWriter.tagIdentifier(with: tag)
    let content = contentsForMessages([message])

    DispatchQueue.main.async {
      self.tagIdLabel.text = "Read Tag Identifier:\(tagId.hexadecimal)"
      self.tagInfoTextView.text = "TagInfo:\n\(tagInfosDetail)\nNFCNDEFMessage:\n\(content)"
    }
    self.readerWriter.end()
}

/// --------------------------------
/// other NFCReaderDelegate methods:
/// --------------------------------
func readerDidBecomeActive(_ session: NFCReader) {
  print("Reader did become")
}
func reader(_ session: NFCReader, didInvalidateWithError error: Error) {
  print("ERROR:\(error)")
}
```

## Requirements
- iOS 11.0+
- Swift 4.2 to 5.2

## Author
Visit my github: [janlionly](https://github.com/janlionly)<br>
Contact with me by email: janlionly@gmail.com

## Contribute
I would love you to contribute to **NFCReaderWriter**

## License
**NFCReaderWriter** is available under the MIT license. See the [LICENSE](https://github.com/janlionly/NFCReaderWriter/blob/master/LICENSE) file for more info.
