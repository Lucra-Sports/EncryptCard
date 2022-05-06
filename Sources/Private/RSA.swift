//
//  File.swift
//  
//
//  Created by Paul Zabelin on 5/2/22.
//

import Foundation

struct RSA {
    let publicKey: SecKey
}

extension RSA: Encryptor {
    func encrypt(data: Data) throws -> Data {
        var error: Unmanaged<CFError>?
        let result = SecKeyCreateEncryptedData(
            publicKey,
            .rsaEncryptionPKCS1,
            data as CFData,
            &error)
        if let failedToEncrypt = error?.takeRetainedValue() {
            throw failedToEncrypt
        }
        return (result! as Data)
    }
}
