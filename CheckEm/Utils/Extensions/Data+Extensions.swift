//
//  String+Extensions.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 25/01/2024.
//

import Foundation

private let base32Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"

enum DataEncodingError: Error {
    case characterNotFoundInBase32Alphabet
}

extension Data {
    
    init(base32Encoded base32String: String) throws {
        var bits = 0
        var value = 0
        var decoded = Data()
        for char in base32String.uppercased() {
            guard let index = base32Alphabet.firstIndex(of: char) else {
                throw DataEncodingError.characterNotFoundInBase32Alphabet
            }
            value = (value << 5) | base32Alphabet.distance(from: base32Alphabet.startIndex, to: index)
            bits += 5
            
            if bits >= 8 {
                decoded.append(UInt8((value >> (bits - 8)) & 0xFF))
                bits -= 8
            }
        }
        self = decoded
    }
}
