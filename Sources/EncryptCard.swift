//
//  Encrypt.swift
//  AcceptanceTests
//
//  Created by Paul Zabelin on 4/30/22.
//

import Foundation

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
    var rsaEncryptFunction: RsaEncryptionFunction = rsaEncrypt(publicKey:data:)

    typealias AesEncryptionFunction = (_ key: Data, _ seed: Data, _ string: String) throws -> String
    var aesEncryptFunction: AesEncryptionFunction = aesEncrypt(key:seed:string:)

    typealias RandomFunction = (_ size: Int) -> Data
    var randomFunction: RandomFunction = secureRandom(size:)

    public func encrypt(_ string: String) throws -> String {
        let randomKey = randomFunction(32)
        let randomSeed = randomFunction(16)
        let encryptedSting = try aesEncryptFunction(randomKey, randomSeed, string)
        return [
            Self.format,
            Self.version,
            keyId,
            try rsaEncryptFunction(publicKey, randomKey),
            randomSeed.base64EncodedString(),
            encryptedSting
        ].joined(separator: "|").data(using: .ascii)!.base64EncodedString()
    }
    
    public func encrypt(creditCard: CreditCard, includeCVV: Bool = true) throws -> String {
        try encrypt(creditCard.directPostString(includeCVV: includeCVV))
    }
}
