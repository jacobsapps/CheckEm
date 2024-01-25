//
//  KeychainManager.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 25/01/2024.
//

import Foundation
import KeychainAccess

final class KeychainManager {
    
    static let shared = KeychainManager()
    private let keychain: Keychain
    
    private init() {
        self.keychain = Keychain()
    }

    func fetchSecret(for accountName: String) -> Data? {
        try? keychain.getData(accountName)
    }
    
    func storeSecret(_ secret: Data, for accountName: String) throws {
        try keychain.set(secret, key: accountName)
    }
    
    func deleteSecret(for accountName: String)
}
