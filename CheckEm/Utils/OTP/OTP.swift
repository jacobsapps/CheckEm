//
//  OTP.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import CryptoKit
import Foundation

struct OTP {
    
    let date: Date
    let code: String
    let interestingness: Interestingness?
    
    var dateString: String {
        Formatters.shared.fullDateFormatter.string(from: date)
    }
    
    init(secret: Data, date: Date = Date(), increment: Int = 0) {
        let period = TimeInterval(30)
        let adjustedDate = date.addingTimeInterval(period * Double(increment)).roundedDownToNearestThirtySeconds
        let counter = UInt64(adjustedDate.timeIntervalSince1970 / period)
        let counterBytes = (0..<8).reversed().map { UInt8(counter >> (8 * $0) & 0xff) }
        let hash = HMAC<Insecure.SHA1>.authenticationCode(for: counterBytes, using: SymmetricKey(data: secret))
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
