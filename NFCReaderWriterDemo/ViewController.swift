//
//  ViewController.swift
//  NFCReaderWriterDemo
//
//  Created by janlionly on 2020/6/4.
//  Copyright © 2020 janlionly. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var tagIdLabel: UILabel!
    @IBOutlet var tagInfoTextView: UITextView!
    @IBOutlet weak var textView: UITextView!
    let readerWriter = NFCReaderWriter.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    // iOS 11 NFC Reader: NFCNDEFMessage
    @IBAction func readButtonTapped(_ sender: Any) {
        readerWriter.newReaderSession(with: self, invalidateAfterFirstRead: false, alertMessage: "Nearby NFC card for read")
        readerWriter.begin()
        self.readerWriter.detectedMessage = "detected NFC Message"
    }
    
    // iOS 13 NFC Writer: write data to record
    @IBAction func writeButtonTapped(_ sender: Any) {
        readerWriter.newWriterSession(with: self, isLegacy: true, invalidateAfterFirstRead: true, alertMessage: "Nearby NFC card for write")
        readerWriter.begin()
        self.readerWriter.detectedMessage = "Write data success"
    }
    
    // iOS 13 NFC Tag Reader: Tag Info and NFCNDEFMessage
    @IBAction func readTagIDButtonTapped(_ sender: Any) {
        readerWriter.newWriterSession(with: self, isLegacy: false, invalidateAfterFirstRead: true, alertMessage: "Nearby NFC card for read tag identifier")
        readerWriter.begin()
        readerWriter.detectedMessage = "detected Tag info"
    }
    
    // MARK: - Utilities
    func contentsForMessages(_ messages: [NFCNDEFMessage]) -> String {
        var recordInfos = ""
        
        for message in messages {
            for (i, record) in message.records.enumerated() {
                recordInfos += "Record(\(i + 1)):\n"
                recordInfos += "Type name format: \(record.typeNameFormat.rawValue)\n"
                recordInfos += "Type: \(record.type as NSData)\n"
                recordInfos += "Identifier: \(record.identifier)\n"
                recordInfos += "Length: \(message.length)\n"
                
                if let string = String(data: record.payload, encoding: .ascii) {
                    recordInfos += "Payload content:\(string)\n"
                }
                recordInfos += "Payload raw data: \(record.payload as NSData)\n\n"
            }
        }
        
        return recordInfos
    }
    
    func getTagInfos(_ tag: __NFCTag) -> [String: Any] {
        var infos: [String: Any] = [:]

        switch tag.type {
        case .miFare:
            if let miFareTag = tag.asNFCMiFareTag() {
                switch miFareTag.mifareFamily {
                case .desfire:
                    infos["TagType"] = "MiFare DESFire"
                case .ultralight:
                    infos["TagType"] = "MiFare Ultralight"
                case .plus:
                    infos["TagType"] = "MiFare Plus"
                case .unknown:
                    infos["TagType"] = "MiFare compatible ISO14443 Type A"
                @unknown default:
                    infos["TagType"] = "MiFare unknown"
                }
                if let bytes = miFareTag.historicalBytes {
                    infos["HistoricalBytes"] = bytes.hexadecimal
                }
                infos["Identifier"] = miFareTag.identifier.hexadecimal
            }
        case .iso7816Compatible:
            if let compatibleTag = tag.asNFCISO7816Tag() {
                infos["TagType"] = "ISO7816"
                infos["InitialSelectedAID"] = compatibleTag.initialSelectedAID
                infos["Identifier"] = compatibleTag.identifier.hexadecimal
                if let bytes = compatibleTag.historicalBytes {
                    infos["HistoricalBytes"] = bytes.hexadecimal
                }
                if let data = compatibleTag.applicationData {
                    infos["ApplicationData"] = data.hexadecimal
                }
                infos["OroprietaryApplicationDataCoding"] = compatibleTag.proprietaryApplicationDataCoding
            }
        case .ISO15693:
            if let iso15693Tag = tag.asNFCISO15693Tag() {
                infos["TagType"] = "ISO15693"
                infos["Identifier"] = iso15693Tag.identifier
                infos["ICSerialNumber"] = iso15693Tag.icSerialNumber.hexadecimal
                infos["ICManufacturerCode"] = iso15693Tag.icManufacturerCode
            }
            
        case .feliCa:
            if let feliCaTag = tag.asNFCFeliCaTag() {
                infos["TagType"] = "FeliCa"
                infos["Identifier"] = feliCaTag.currentIDm
                infos["SystemCode"] = feliCaTag.currentSystemCode.hexadecimal
            }
        default:
            break
        }
        return infos
    }
}

extension ViewController: NFCReaderDelegate {
    func readerDidBecomeActive(_ session: NFCReader) {
        print("Reader did become")
    }
    
    func reader(_ session: NFCReader, didInvalidateWithError error: Error) {
            print("ERROR:\(error)")
            readerWriter.end()
        }

    /// -----------------------------
    // MARK: - 1. NFC Reader(iOS 11):
    /// -----------------------------
    func reader(_ session: NFCReader, didDetectNDEFs messages: [NFCNDEFMessage]) {
        let  recordInfos = contentsForMessages(messages)

        DispatchQueue.main.async {
            self.textView.text = recordInfos
        }
        readerWriter.end()
    }

    /// -----------------------------
    // MARK: - 2. NFC Writer(iOS 13):
    /// -----------------------------
    func reader(_ session: NFCReader, didDetect tags: [NFCNDEFTag]) {
        print("did detect tags")

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
    
    /// --------------------------------
    // MARK: - 3. NFC Tag Reader(iOS 13)
    /// --------------------------------
    func reader(_ session: NFCReader, didDetect tag: __NFCTag, didDetectNDEF message: NFCNDEFMessage) {
        let tagId = readerWriter.tagIdentifier(with: tag)
        let content = contentsForMessages([message])
        
        let tagInfos = getTagInfos(tag)
        var tagInfosDetail = ""
        tagInfos.forEach { (item) in
            tagInfosDetail = tagInfosDetail + "\(item.key): \(item.value)\n"
        }
        
        DispatchQueue.main.async {
            self.tagIdLabel.text = "Read Tag Identifier:\(tagId.hexadecimal)"
            self.tagInfoTextView.text = "TagInfo:\n\(tagInfosDetail)\nNFCNDEFMessage:\n\(content)"
        }
        self.readerWriter.end()
    }
}

extension Data {
    /// Hexadecimal string representation of `Data` object.
    var hexadecimal: String {
        return map { String(format: "%02x", $0) }
            .joined()
    }
}

