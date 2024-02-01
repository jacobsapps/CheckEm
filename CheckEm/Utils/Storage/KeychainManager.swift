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
        self.keychain = Keychain().synchronizable(true)
    }
    
    func fetchAll() throws -> [String] {
        keychain
            .allItems()
            .compactMap { $0["value"] as? String }
    }

    func storeAccount(named name: String, url: URL) throws {
        try keychain.set(url.absoluteString, key: name)
    }
    
    func deleteAccount(named name: String) throws {
        try keychain.remove(name)
    }
}
