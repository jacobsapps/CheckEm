//
//  DatabaseManager.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 25/01/2024.
//

import Foundation
import SwiftData

struct Account: Identifiable, Equatable {
    
    static func == (lhs: Account, rhs: Account) -> Bool {
        (lhs.name == rhs.name)
    }
    
    var id: String {
        name
    }
    
    let name: String
    let issuer: String
    let dateCreated: Date
    let secret: Data
    var currentCode: CurrentCode?
 
    init(name: String, base32String: String, issuer: String) throws {
        self.name = name
        self.issuer = issuer
        self.dateCreated = Date()
        self.secret = try Data(base32Encoded: base32String)
    }
    
    func refresh(date: Date) {
        currentCode?.refresh(date: date, secret: secret)
    }
}

final class CurrentCode {
    
    var code: String?
    var countdown: Int?
    private var dateCodeExpires: Date?
    
    func refresh(date: Date, secret: Data) {
        if let dateCodeExpires,
            date < (dateCodeExpires) {
            
        } else {
            recomputeCode(secret: secret)
        }
        
        if let dateCodeExpires {
            countdown = Int(dateCodeExpires.timeIntervalSince(date).rounded())
        }
    }
    
    private func recomputeCode(secret: Data) {
        guard let otp = CodeGenerator.shared.currentCode(secret: secret) else { return }
        code = otp.code
        dateCodeExpires = otp.dateExpires
    }
}
