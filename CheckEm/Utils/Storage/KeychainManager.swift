//
//  KeychainManager.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 25/01/2024.
//

import Foundation
import KeychainAccess

final class KeychainManager {
    
    enum KeychainManagerError: Error {
        case accountsNotFound
        case accountNotFound
    }
    
    static let shared = KeychainManager()
    private let keychain: Keychain
    
    private init() {
        self.keychain = Keychain()
    }
    
    func fetchAllAccounts() throws -> [[String: URL]] {
        guard let items = keychain.allItems() as? [[String: URL]] else {
            throw KeychainManagerError.accountsNotFound
        }
        print(items)
        return items
    }
    
    func fetchAccount(named name: String) throws -> Account {
        guard let urlString = try keychain.get(name),
              let url = URL(string: urlString),
              let account = SecretURLParser.shared.account2FA(from: url) else {
            throw KeychainManagerError.accountNotFound
        }
        return account
    }
    
    func storeAccount(named name: String, url: URL) throws {
        try keychain.set(url.absoluteString, key: name)
    }
    
    func deleteAccount(named name: String) throws {
        try keychain.remove(name)
    }
}
