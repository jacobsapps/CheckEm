//
//  DatabaseManager.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 25/01/2024.
//

import Foundation
import SwiftData

// TODO: Store the whole TOTP QR code in the keychain, then hold it in memory
// #error("Maybe the whole TOTP QR should be in the keychain, and held in memory after retrieving it and reconstructing from there")
// how to keep the keychain on icloud?

@Model
final class Account {
    
    @Attribute(.unique) var name: String
    var issuer: String
    var dateCreated: Date
    var code: String?
    var dateCodeRefreshed: Date?
    var dateCodeExpires: Date?
    var countdown: String?
    var secret: Data? {
        try? KeychainManager.shared.fetchSecret(for: name)
    }
    
    init(name: String, base32String: String, issuer: String) throws {
        self.name = name
        self.issuer = issuer
        self.dateCreated = Date()
        let secretData = try Data(base32Encoded: base32String)
        try KeychainManager.shared.storeSecret(secretData, for: name)
    }
    
    func refresh(date: Date) {
        
        // only
        // store expiry date of code? so it isnt recomputed every second 
        
        code = CodeGenerator.shared.currentCode(account: self)?.code
        countdown = "\(Int(date.timeLeftInThirtySeconds.rounded()))"
        
//        var dateCodeRefreshed: Date?
//        var dateCodeExpires: Date?
        
    }
}

final class DatabaseManager {
    
    private let container: ModelContainer
    
    static let shared = DatabaseManager()
    
    private init() {
        container = try! ModelContainer(for: Account.self)
    }
    
    @MainActor
    func getAccounts() throws -> [Account] {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<Account>(
            sortBy: [SortDescriptor<Account>(\.dateCreated)]
        )
        return try context.fetch(fetchDescriptor)
    }
    
    @MainActor
    func save(account: Account) throws {
        let context = container.mainContext
        context.insert(account)
        try context.save()
    }
}
