//
//  OTP.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import CryptoKit
import Foundation

//private let secret = Data(base64Encoded: "JBSWY3DPEHPK3PXP")!
private let base32Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"

struct Account {

    let name: String
    let secret: Data
    
    init?(name: String, base32String: String) {
        var bits = 0
        var value = 0
        var decoded = Data()
        for char in base32String.uppercased() {
            guard let index = base32Alphabet.firstIndex(of: char) else {
                return nil
            }
            value = (value << 5) | base32Alphabet.distance(from: base32Alphabet.startIndex, to: index)
            bits += 5

            if bits >= 8 {
                decoded.append(UInt8((value >> (bits - 8)) & 0xFF))
                bits -= 8
            }
        }
        self.name = name
        self.secret = decoded
    }
}

struct OTP {
    
    let date: Date
    let code: String
    let interestingness: Interestingness?
    
    var dateString: String {
        Formatters.shared.fullDateFormatter.string(from: date)
    }
    
    init(account: Account, date: Date = Date(), increment: Int = 0) {
        let period = TimeInterval(30)
        let adjustedDate = date.addingTimeInterval(period * Double(increment)).roundedDownToNearestThirtySeconds
        let counter = UInt64(adjustedDate.timeIntervalSince1970 / period)
        let counterBytes = (0..<8).reversed().map { UInt8(counter >> (8 * $0) & 0xff) }
        let hash = HMAC<Insecure.SHA1>.authenticationCode(for: counterBytes, using: SymmetricKey(data: account.secret))
        let offset = Int(hash.suffix(1)[0] & 0x0f)
        let hash32 = hash
            .dropFirst(offset)
            .prefix(4)
            .reduce(0, { ($0 << 8) | UInt32($1) })
        let hash31 = hash32 & 0x7FFF_FFFF
        let digits = 6
        let pad = String(repeating: "0", count: digits)
        let code = String((pad + String(hash31)).suffix(digits))
        
        self.date = adjustedDate
        self.code = code
        self.interestingness = Interestingness(code: code)
    }
}
