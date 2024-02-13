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
    
    func fetchAccounts() throws -> [Account] {
        try KeychainManager.shared.fetchAccounts()
            .compactMap { createAccount(from: $0) }
            .sorted()
    }
    
    func save(account: Account, url: URL, increment: Int) throws {
        let orderedAccountURL = url.appending(queryItems: [URLQueryItem(name: "order", value: "\(increment)")])
        try KeychainManager.shared.storeAccount(named: account.name, url: orderedAccountURL)
    }
    
    func delete(account: Account) throws {
        try? KeychainManager.shared.deleteAccount(named: account.name)
    }
    
    private func createAccount(from urlString: String) -> Account? {
        guard let url = URL(string: urlString),
              let account = SecretURLParser.shared.account2FA(from: url) else {
            return nil
        }
        return account
    }
}
