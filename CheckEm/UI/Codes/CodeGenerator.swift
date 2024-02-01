//
//  CodeGenerator.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import Combine
import Foundation

final class CodeGenerator {
    
    enum Constants {
        /// There is a limit of 64 locally-scheduled notifications at any one time
        ///
        static let localNotificationLimit: Int = 64
    }
    
    static let shared = CodeGenerator()
    
    var codeSubject = PassthroughSubject<(OTP, Int), Never>()
    
    private init() { }
    
    func currentCode(secret: Data) -> OTP? {
        OTP(secret: secret, eligible: eligibleInterestingness())
    }
    
    func generateCodes(accounts: [Account]) -> Date? {
        let secrets = accounts.compactMap { $0.secret }
        let userInterestingnessSettings = eligibleInterestingness()
        print(userInterestingnessSettings)
        guard !secrets.isEmpty,
              !userInterestingnessSettings.isEmpty else { return nil }
        let date = Date()
        var interestingCodes = [OTP]()
        var increment = 0
        var interestingCodesCount = 0
        var lastCodeDate: Date?
        // 64 limit, 2 come-back notifications
        while interestingCodesCount < (Constants.localNotificationLimit - 2) {
            secrets.forEach {
                let otp = OTP(secret: $0, date: date, increment: increment, eligible: userInterestingnessSettings)
                if otp.interestingness != nil {
                    interestingCodes.append(otp)
                    interestingCodesCount += 1
                    codeSubject.send((otp, interestingCodesCount))
                    if let latestDate = lastCodeDate {
                        lastCodeDate = max(otp.dateStarted, latestDate)
                    } else {
                        lastCodeDate = otp.dateStarted
                    }
                }
            }
            increment += 1
        }
        return lastCodeDate
    }
    
    private func eligibleInterestingness() -> Set<Interestingness> {
        var interestingness = Set<Interestingness>()
        if UserDefaults.standard.bool(forKey: "sexts") {
            interestingness.insert(.sexts)
        }
        if UserDefaults.standard.bool(forKey: "quints") {
            interestingness.insert(.quints)
        }
        if UserDefaults.standard.bool(forKey: "nearlySextuples") {
            interestingness.insert(.nearlySextuples)
        }
        if UserDefaults.standard.bool(forKey: "quads") {
            interestingness.insert(.quads)
        }
        if UserDefaults.standard.bool(forKey: "count") {
            interestingness.insert(.counting)
        }
        if UserDefaults.standard.bool(forKey: "palindrome") {
            interestingness.insert(.palindrome)
        }
        if UserDefaults.standard.bool(forKey: "repeatedThrees") {
            interestingness.insert(.repeatedThrees)
        }
        if UserDefaults.standard.bool(forKey: "repeatedTwos") {
            interestingness.insert(.repeatedTwos)
        }
        if UserDefaults.standard.bool(forKey: "units") {
            interestingness.insert(.units)
        }
        if UserDefaults.standard.bool(forKey: "hunderedThousands") {
            interestingness.insert(.hunderedThousands)
        }
        if UserDefaults.standard.bool(forKey: "tens") {
            interestingness.insert(.tens)
        }
        if UserDefaults.standard.bool(forKey: "mathematicalConstants") {
            interestingness.insert(.pi)
            interestingness.insert(.e)
            interestingness.insert(.phi)
            interestingness.insert(.rootTwo)
            interestingness.insert(.aperysConstant)
            interestingness.insert(.eulersConstant)
        }
        if UserDefaults.standard.bool(forKey: "physicalConstants") {
            interestingness.insert(.speedOfLight)
            interestingness.insert(.planksConstant)
            interestingness.insert(.avogadrosConstant)
            interestingness.insert(.gravitationalConstant)
            interestingness.insert(.charge)
            interestingness.insert(.boltzmannConstant)
            interestingness.insert(.fineStructureConstant)
            interestingness.insert(.vacuumPermittivity)
        }
        return interestingness
    }
}
