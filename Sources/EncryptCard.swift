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
        guard key.hasPrefix(Self.padding) && key.hasSuffix(Self.padding) else {
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
    
    var rsaEncryptFunction: FunctionType.RSA = rsaEncrypt(publicKey:data:)
    var aesEncryptFunction: FunctionType.AES = aesEncrypt(key:seed:data:)
    var randomFunction: FunctionType.SecureRandom = secureRandom(size:)
    lazy var publicEncryptor: Encryptor = RSA(publicKey: publicKey)
    var privateEncryptorFactory: () -> PrivateEncryptor = { AES() }

    public func encrypt(_ string: String) throws -> String {
        let aes = privateEncryptorFactory()
        return [
            Self.format,
            Self.version,
            keyId,
            try rsaEncryptFunction(publicKey, aes.key),
            aes.seed.base64EncodedString(),
            try aes.encrypt(string: string)
        ].joined(separator: "|").data(using: .ascii)!.base64EncodedString()
    }
    
    public func encrypt(creditCard: CreditCard, includeCVV: Bool = true) throws -> String {
        try encrypt(creditCard.directPostString(includeCVV: includeCVV))
    }
}
