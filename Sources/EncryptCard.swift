//
//  Encrypt.swift
//  AcceptanceTests
//
//  Created by Paul Zabelin on 4/30/22.
//

import Foundation
import CryptoSwift

public class EncryptCard {
    public enum Error: Swift.Error {
        case invalidKey(String)
        case invalidCertificate
        case invalidCard
        case failedToEncrypt
    }
    
    public let keyId: String
    public let publicKey: SecKey
    public let subject: String
    
    public init(key: String) throws {
        if !key.hasPrefix(Self.padding) || !key.hasSuffix(Self.padding) {
            throw Error.invalidKey("Key is not valid. Should start and end with '***'")
        }
        let keys = key.trimmingCharacters(in: .init(charactersIn: "*"))
            .components(separatedBy: .init(charactersIn: "\\|"))
        keyId = keys.first!
        
        if let keyBody = keys.last,
           let data = Data(base64Encoded: keyBody),
           let certificate = SecCertificateCreateWithData(kCFAllocatorDefault, data as CFData),
           let secKey = SecCertificateCopyKey(certificate),
           SecKeyIsAlgorithmSupported(secKey, .encrypt, .rsaEncryptionPKCS1),
           let summary = SecCertificateCopySubjectSummary(certificate) {
            publicKey = secKey
            subject = summary as String
        } else {
            throw Error.invalidCertificate
        }

    }
    
    static let padding = "***"
    static let format = "GWSC"
    static let version = "1"
    
    typealias RsaEncryptionFunction = (_ publicKey: SecKey, _ data: Data) throws -> String
    var rsaEncryptFunction: RsaEncryptionFunction = rsaEncrypt
    
    public func encrypt(_ string: String) throws -> String {
        let randomKey = AES.randomIV(32)
        let randomSeed = AES.randomIV(16)
        let cypher = try AES(key: randomKey, blockMode: CBC(iv: randomSeed), padding: .pkcs5)
        return [
            Self.format,
            Self.version,
            keyId,
            try rsaEncryptFunction(publicKey, Data(randomKey)),
            randomSeed.toBase64(),
            try cypher.encrypt(string.bytes).toBase64()
        ].joined(separator: "|").bytes.toBase64()
    }
    
    public func encrypt(creditCard: CreditCard, includeCVV: Bool = true) throws -> String {
        try encrypt(creditCard.directPostString(includeCVV: includeCVV))
    }
}
