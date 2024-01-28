//
//  CodeGenerator.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import Foundation

final class CodeGenerator {
    
    private enum Constants {
        /// There is a limit of 64 locally-scheduled notifications at any one time
        ///
        static let localNotificationLimit: Int = 64
    }
    
    static let shared = CodeGenerator()
    
    private init() { }
    
    func currentCode(secret: Data) -> OTP? {
        OTP(secret: secret)
    }
    
    func generateCodes(accounts: [Account]) -> [OTP] {
        let secrets = accounts.compactMap { $0.secret }
        guard !secrets.isEmpty else { return [] }
        let date = Date()
        var interestingCodes = [OTP]()
        var increment = 0
        var interestingCodesCount = 0
        while interestingCodesCount < Constants.localNotificationLimit {
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
