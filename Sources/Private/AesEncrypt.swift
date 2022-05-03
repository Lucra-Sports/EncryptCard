//
//  File.swift
//  
//
//  Created by Paul Zabelin on 5/2/22.
//

import Foundation
import CommonCrypto

func aesEncrypt(key: Data, seed: Data, string: String) throws -> String {
    let padLength = kCCBlockSizeAES128
    var resultLength: size_t = 0
    let cCharArray = string.utf8CString
    var result = Data(repeating: .zero, count: cCharArray.count + padLength)
    let error = result.withUnsafeMutableBytes { buffer  in
        seed.withUnsafeBytes { seedBytes in
            key.withUnsafeBytes { keyBytes in
                cCharArray.withUnsafeBytes { stringBuffer in
                    CCCrypt(
                        CCOperation(kCCEncrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        CCOptions(kCCOptionPKCS7Padding),
                        keyBytes.baseAddress, key.count,
                        seedBytes.baseAddress,
                        stringBuffer.baseAddress, cCharArray.count - 1,
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
    return result[0..<resultLength].base64EncodedString()
}

