//
//  DatabaseManager.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 25/01/2024.
//

import Foundation
import SwiftData

@Model
final class Account {
    
    @Attribute(.unique) var name: String
    var secret: Data? {
        KeychainManager.shared.fetchSecret(for: name)
    }
    
    init(name: String, base32String: String) throws {
        self.name = name
        let secretData = try Data(base32Encoded: base32String)
        try KeychainManager.shared.storeSecret(secretData, for: name)
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
            sortBy: [SortDescriptor<Account>(\.name)]
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
