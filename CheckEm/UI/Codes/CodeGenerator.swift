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
    
    func currentCode() -> OTP {
        OTP()
    }
    
    // idea: generate these with paging, and every time an interesting one gets created, set the notif. immediately; then update a datepicker with the date it sends 
    func generateCodes() -> [OTP] {
        let date = Date()
        return (0..<10_000)
            .map { OTP(date: date, increment: $0) }
            .filter { $0.interestingness != nil }
    }
}
