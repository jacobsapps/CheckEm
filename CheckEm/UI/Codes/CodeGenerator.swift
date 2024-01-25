//
//  CodeGenerator.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import Foundation

final class CodeGenerator {
    
    static let shared = CodeGenerator()
    
    private init() { }
    
    func currentCode(account: Account) -> OTP? {
        guard let secret = account.secret else { return nil }
        return OTP(secret: secret)
    }
    
    // There is a 64 notification limit on locally-scheduled notifications
    func generateCodes(accounts: [Account]) -> [OTP] {
        let secrets = accounts.compactMap { $0.secret }
        let date = Date()
        var interestingCodes = [OTP]()
        var increment = 0
        var interestingCodesCount = 0
        while interestingCodesCount < 64 {
            secrets.forEach {
                let otp = OTP(secret: $0, date: date, increment: increment)
                if otp.interestingness != nil {
                    interestingCodes.append(otp)
                    interestingCodesCount += 1
                }
            }
            increment += 1
        }
        return interestingCodes
    }
}
