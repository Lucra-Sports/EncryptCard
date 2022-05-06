//
//  File.swift
//  
//
//  Created by Paul Zabelin on 5/2/22.
//

import Foundation
import CommonCrypto

struct AES {
    let key: Data
    let seed: Data
    
    init(key: Data, seed: Data) {
        self.key = key
        self.seed = seed
    }
    init() {
        self.init(
            key: secureRandom(size: kCCKeySizeAES256),
            seed: secureRandom(size: kCCBlockSizeAES128)
        )
    }
}

extension AES: PrivateEncryptor {
    func encrypt(data: Data) throws -> Data {
        let padLength = kCCBlockSizeAES128
        var resultLength: size_t = 0
        var result = Data(repeating: .zero, count: data.count + padLength)
        let error = result.withUnsafeMutableBytes { buffer  in
            seed.withUnsafeBytes { seedBytes in
                key.withUnsafeBytes { keyBytes in
                    data.withUnsafeBytes { stringBuffer in
                        CCCrypt(
                            CCOperation(kCCEncrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress, key.count,
                            seedBytes.baseAddress,
                            stringBuffer.baseAddress, data.count,
                            buffer.baseAddress, buffer.count,
                            &resultLength
                        )
                    }
                }
            }
        }
        guard error == kCCSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(error))
        }
        return result[0..<resultLength]
    }
}
