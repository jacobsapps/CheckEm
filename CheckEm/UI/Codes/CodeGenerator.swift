//
//  CodeGenerator.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import Foundation

final class CodeGenerator {
    
    private let account: Account
    
    init(account: Account) { 
        self.account = account
    }
    
    func currentCode() -> OTP {
        OTP(account: account)
    }
    
    // TODO: generate these with paging,
    // and every time an interesting one gets created,
    // set the notif. immediately; then update a
    // datepicker with the date it sends
    func generateCodes() -> [OTP] {
        let date = Date()
        return (0..<100_000)
            .map { OTP(account: account, date: date, increment: $0) }
            .filter { $0.interestingness != nil }
    }
}
