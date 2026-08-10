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
        static let availableBackgroundCores: Int = max(1, ProcessInfo.processInfo.processorCount - 1)
    }
    
    static let shared = CodeGenerator()
    
    var codeSubject = PassthroughSubject<OTP, Never>()
    
    private init() { }
    
    func currentCode(secret: Data) -> OTP? {
        OTP(secret: secret, eligible: eligibleInterestingness())
    }
    
    func generateCodes(accounts: [Account], incrementor: CodeIncrementActor) async {
        let secrets = accounts.compactMap { $0.secret }
        let userInterestingnessSettings = eligibleInterestingness()
        
        guard !secrets.isEmpty,
              !userInterestingnessSettings.isEmpty else { return }

        let date = Date()

        while Double(await incrementor.codes) < (Double(Constants.localNotificationLimit - 2)) {
            let increment = await incrementor.increment()
            for secret in secrets {
                let otp = OTP(secret: secret, date: date, increment: increment, eligible: userInterestingnessSettings)
                if otp.interestingness != nil,
                   await incrementor.newCodeFound(at: otp.dateStarted) {
                    codeSubject.send(otp)
                }
            }
        }
    }
    
    func initializeDefaultsIfRequired() {
        let defaults = UserDefaults.standard
        
        guard defaults.object(forKey: "sexts") == nil else { return }
        
        let defaultTrue = ["sexts",
                           "count",
                           "hunderedThousands",
                           "units",
                           "mathematicalConstants",
                           "physicalConstants",
                           "quints",
                           "repeatedTwos",
                           "tens",
                           "nearlyCounting"]
        
        defaultTrue.forEach {
            defaults.set(true, forKey: $0)
        }
        
        let defaultFalse = ["nearlySextuples",
                            "palindrome",
                            "repeatedThrees",
                            "quads"]
        
        defaultFalse.forEach {
            defaults.set(false, forKey: $0)
        }
    }
    
    private func eligibleInterestingness() -> Set<Interestingness> {
        let defaults = UserDefaults.standard
        var interestingness = Set<Interestingness>()
        if defaults.bool(forKey: "sexts") {
            interestingness.insert(.sexts)
        }
        if defaults.bool(forKey: "quints") {
            interestingness.insert(.quints)
        }
        if defaults.bool(forKey: "nearlySextuples") {
            interestingness.insert(.nearlySextuples)
        }
        if defaults.bool(forKey: "quads") {
            interestingness.insert(.quads)
        }
        if defaults.bool(forKey: "count") {
            interestingness.insert(.counting)
        }
        if defaults.bool(forKey: "palindrome") {
            interestingness.insert(.palindrome)
        }
        if defaults.bool(forKey: "repeatedThrees") {
            interestingness.insert(.repeatedThrees)
        }
        if defaults.bool(forKey: "repeatedTwos") {
            interestingness.insert(.repeatedTwos)
        }
        if defaults.bool(forKey: "units") {
            interestingness.insert(.units)
        }
        if defaults.bool(forKey: "hunderedThousands") {
            interestingness.insert(.hunderedThousands)
        }
        if defaults.bool(forKey: "tens") {
            interestingness.insert(.tens)
        }
        if defaults.bool(forKey: "nearlyCounting") {
            interestingness.insert(.nearlyCounting)
        }
        if defaults.bool(forKey: "mathematicalConstants") {
            interestingness.insert(.pi)
            interestingness.insert(.e)
            interestingness.insert(.phi)
            interestingness.insert(.rootTwo)
            interestingness.insert(.aperysConstant)
            interestingness.insert(.eulersConstant)
        }
        if defaults.bool(forKey: "physicalConstants") {
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
