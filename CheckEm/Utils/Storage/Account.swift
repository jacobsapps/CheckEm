//
//  DatabaseManager.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 25/01/2024.
//

import Foundation
import SwiftData

struct Account {
    
    let name: String
    let issuer: String
    let dateCreated: Date
    let secret: Data
    var code: String?
    var countdown: Int?
    private var dateCodeExpires: Date?
    
    init(name: String, base32String: String, issuer: String) throws {
        self.name = name
        self.issuer = issuer
        self.dateCreated = Date()
        self.secret = try Data(base32Encoded: base32String)
    }
    
    func resetUI() -> Account {
        var copy = self
        copy.dateCodeExpires = nil
        copy.code = nil
        copy.countdown = nil
        return copy
    }
    
    func refreshed(date: Date) -> Account {
        
        var copy = self
        
        if let dateCodeExpires,
            date < (dateCodeExpires) {
            let countdown = Int(dateCodeExpires.timeIntervalSince(date).rounded(.up))
            copy.countdown = (countdown <= 0) ? 0 : countdown
            
        } else {
            guard let otp = CodeGenerator.shared.currentCode(secret: secret) else { return copy }
            copy.code = otp.code
            copy.dateCodeExpires = otp.dateExpires
            let countdown = Int(otp.dateExpires.timeIntervalSince(date).rounded(.up))
            copy.countdown = (countdown <= 0) ? 0 : countdown
        }
        
        return copy
    }
}
