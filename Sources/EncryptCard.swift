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
    
    public convenience init(key: String) throws {
        guard key.hasPrefix(Self.padding) && key.hasSuffix(Self.padding) else {
            throw Error.invalidKey("Key is not valid. Should start and end with '***'")
        }
        let keys = key.trimmingCharacters(in: .init(charactersIn: "*"))
            .components(separatedBy: .init(charactersIn: "\\|"))
        
        if let keyBody = keys.last, let data = Data(base64Encoded: keyBody) {
            try self.init(keyId: keys.first!, certificate: data)
        } else {
            throw Error.invalidKey("Key is not valid. Should be Base64 encoded")
        }
    }
    
    public init(keyId: String, certificate data: Data) throws {
        if let certificate = SecCertificateCreateWithData(kCFAllocatorDefault, data as CFData),
           let secKey = SecCertificateCopyKey(certificate),
           SecKeyIsAlgorithmSupported(secKey, .encrypt, .rsaEncryptionPKCS1),
           let summary = SecCertificateCopySubjectSummary(certificate) {
            self.keyId = keyId
            self.publicKey = secKey
            self.subject = summary as String
        } else {
            throw Error.invalidCertificate
        }
    }
    
    static let padding = "***"
    static let format = "GWSC"
    static let version = "1"
    
    lazy var publicEncryptor: Encryptor = RSA(publicKey: publicKey)
    var createPrivateEncryptor: () -> PrivateEncryptor = AES.init

    public func encrypt(creditCard: CreditCard, includeCVV: Bool = true) throws -> String {
        try encrypt(string: creditCard.directPostString(includeCVV: includeCVV))
    }
}

extension EncryptCard: Encryptor {
    func encrypt(data: Data) throws -> Data {
        let privateEncryptor = createPrivateEncryptor()
        return [
            Self.format,
            Self.version,
            keyId,
            try publicEncryptor.encrypt(data: privateEncryptor.key),
            privateEncryptor.seed.base64,
            try privateEncryptor.encrypt(data: data)
        ].joined(separator: "|").utf8
    }
}
