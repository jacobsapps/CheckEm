//
//  AccountManager.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 28/01/2024.
//

import Foundation

final class AccountManager {
    
    static let shared = AccountManager()

    private init() { }

    @MainActor
    func getAccounts() throws -> [Account] {
        let urls = try KeychainManager.shared.fetchAllAccounts()
        print(urls)
        return []
    }

    @MainActor
    func save(account: Account) throws {
        // KeychainManager.shared.storeSecret(, for: )
    }
    
    @MainActor
    func delete(account: Account) throws {
//         KeychainManager.shared.deleteSecret(for: )
    }
}
