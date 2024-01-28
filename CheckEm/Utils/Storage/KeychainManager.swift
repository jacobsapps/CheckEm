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
        case dataNotFound
    }
    
    static let shared = KeychainManager()
    private let keychain: Keychain
    
    private init() {
        self.keychain = Keychain()
    }

    func fetchSecret(for accountName: String) throws -> Data {
        guard let data = try keychain.getData(accountName) else {
            throw KeychainManagerError.dataNotFound
        }
        return data
    }
    
    func storeSecret(_ secret: Data, for accountName: String) throws {
        try keychain.set(secret, key: accountName)
    }
    
    func deleteSecret(for accountName: String) throws {
        try keychain.remove(accountName)
    }
}
