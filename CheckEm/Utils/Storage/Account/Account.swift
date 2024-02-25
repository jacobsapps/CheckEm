//
//  DatabaseManager.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 25/01/2024.
//

import Foundation
import SwiftData

struct Account: Comparable {
    
    let name: String
    let issuer: String
    let dateCreated: Date
    let secret: Data
    let order: Int
    var code: String?
    var countdown: Int?
    private var dateCodeExpires: Date?
    
    static func < (lhs: Account, rhs: Account) -> Bool {
        lhs.order < rhs.order
    }
    
    init(name: String, base32String: String, issuer: String, order: Int) throws {
        self.name = name
        self.issuer = issuer
        self.dateCreated = Date()
        self.secret = try Data(base32Encoded: base32String)
        self.order = order
    }
    
    private init(name: String,
                 issuer: String,
                 dateCreated: Date,
                 secret: Data,
                 order: Int) {
        self.name = name
        self.issuer = issuer
        self.dateCreated = dateCreated
        self.secret = secret
        self.order = order
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
    
    func withOrder(_ newOrder: Int) -> Account {
        Account(name: name,
                issuer: issuer,
                dateCreated: dateCreated,
                secret: secret,
                order: newOrder)
    }
}
