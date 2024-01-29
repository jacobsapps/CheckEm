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
        OTP(secret: secret, eligible: eligibleInterestingness())
    }
    
    func generateCodes(accounts: [Account]) -> [OTP] {
        let secrets = accounts.compactMap { $0.secret }
        let userInterestingnessSettings = eligibleInterestingness()
        guard !secrets.isEmpty,
              !userInterestingnessSettings.isEmpty else { return [] }
        let date = Date()
        var interestingCodes = [OTP]()
        var increment = 0
        var interestingCodesCount = 0
        while interestingCodesCount < (Constants.localNotificationLimit - 1) {
            secrets.forEach {
                let otp = OTP(secret: $0, date: date, increment: increment, eligible: userInterestingnessSettings)
                if otp.interestingness != nil {
                    interestingCodes.append(otp)
                    interestingCodesCount += 1
                }
            }
            increment += 1
        }
        return interestingCodes
    }
    
    private func eligibleInterestingness() -> Set<Interestingness> {
        var interestingness = Set<Interestingness>()
        if UserDefaults.standard.bool(forKey: "sexts") == Optional<Bool>.some(true) {
            interestingness.insert(.sexts)
        }
        if UserDefaults.standard.bool(forKey: "quints") == Optional<Bool>.some(true) {
            interestingness.insert(.quints)
        }
        if UserDefaults.standard.bool(forKey: "nearlySextuples") == Optional<Bool>.some(true) {
            interestingness.insert(.nearlySextuples)
        }
        if UserDefaults.standard.bool(forKey: "quads") == Optional<Bool>.some(true) {
            interestingness.insert(.quads)
        }
        if UserDefaults.standard.bool(forKey: "count") == Optional<Bool>.some(true) {
            interestingness.insert(.counting)
        }
        if UserDefaults.standard.bool(forKey: "palindrome") == Optional<Bool>.some(true) {
            interestingness.insert(.palindrome)
        }
        if UserDefaults.standard.bool(forKey: "repeated") == Optional<Bool>.some(true) {
            interestingness.insert(.repeated)
        }
        if UserDefaults.standard.bool(forKey: "mathematicalConstants") == Optional<Bool>.some(true) {
            interestingness.insert(.pi)
            interestingness.insert(.e)
            interestingness.insert(.phi)
        }
        if UserDefaults.standard.bool(forKey: "physicalConstants") == Optional<Bool>.some(true) {
            interestingness.insert(.speedOfLight)
            interestingness.insert(.planksConstant)
            interestingness.insert(.charge)
        }
        return interestingness
    }
}
