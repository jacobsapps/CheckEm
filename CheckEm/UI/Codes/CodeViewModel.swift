//
//  CodeViewModel.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import Foundation

@Observable
final class CodeViewModel {
    
    var accounts: [Account] = [] 
    
    @MainActor
    func task() async {
        guard let accounts = try? AccountManager.shared.getAccounts() else { return }
        self.accounts = accounts
        regenerateNotifications()
    }
    
    @MainActor
    func create(account: Account) {
        accounts.append(account)
        try? AccountManager.shared.save(account: account)
        regenerateNotifications()
    }
    
    @MainActor
    func refresh() {
        let date = Date()
        accounts.forEach {
            $0.refresh(date: date)
        }
    }
    
    @MainActor
    func delete(at offsets: IndexSet) {
        let deletedAccounts = accounts.enumerated().filter { offsets.contains($0.offset) }.map { $0.element }
        deletedAccounts.forEach {
            try? KeychainManager.shared.deleteAccount(named: $0.name)
        }
        accounts.remove(atOffsets: offsets)
    }
    
    private func regenerateNotifications() {
        let interestingCodes = CodeGenerator.shared.generateCodes(accounts: accounts)
        NotificationScheduler.shared.cancelNotifications()
        interestingCodes.forEach {
            NotificationScheduler.shared.scheduleNotification(for: $0)
        }
    }
}
