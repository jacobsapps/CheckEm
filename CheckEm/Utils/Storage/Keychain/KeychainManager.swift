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
    
    private enum Constants {
        static let collectionKey = "collection"
    }
    
    static let shared = KeychainManager()
    private let keychain: Keychain
    
    private init() {
        self.keychain = Keychain().synchronizable(true)
    }
    
    // MARK: - Account
    
    private func hardcodedTestAccounts() -> [String] {
        [
            "otpauth://totp/Github?secret=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD&issuer=github",
            "otpauth://totp/Cloudflare?secret=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC&issuer=cloudflare",
            "otpauth://totp/Google?secret=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA&issuer=google",
            "otpauth://totp/Outlook?secret=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB&issuer=outlook"
        ]
    }
    
    func fetchAccounts() throws -> [String] {
       hardcodedTestAccounts()
//        keychain
//            .allItems()
//            .compactMap { $0["value"] as? String }
    }
    
    func storeAccount(named name: String, url: URL) throws {
        try keychain.set(url.absoluteString, key: name)
    }
    
    func deleteAccount(named name: String) throws {
        try keychain.remove(name)
    }
    
    // MARK: - Collection
    
    func fetchCollection() throws -> String? {
        "000000,123456,314159,661034,555556,123321,000010,271828"
//        try keychain.get(Constants.collectionKey)
    }

    func storeCollectionItem(code: String) throws {
        var collection = try keychain.get(Constants.collectionKey) ?? ""
        if !collection.isEmpty {
            collection.append(",")
        }
        collection.append(code)
        try keychain.set(collection, key: Constants.collectionKey)
    }
    
    func deleteCollection() throws {
        try keychain.remove(Constants.collectionKey)
    }
}
