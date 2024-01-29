//
//  CodeViewModel.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import SwiftUI

@Observable
final class CodeViewModel {
        
    var accounts: [Account] = []
    
    @MainActor
    func task() async {
        guard let accounts = try? AccountManager.shared.fetchAccounts() else { return }
        withAnimation {
            self.accounts = accounts
        }
        recomputeNotifications()
    }
    
    @MainActor
    func create(account: Account, url: URL) throws {
        try AccountManager.shared.save(account: account, url: url)
        withAnimation {
            accounts.append(account)
        }
        recomputeNotifications()
    }
    
    @MainActor
    func refresh() {
        let date = Date()
        withAnimation {
            accounts = accounts.map { $0.refreshed(date: date) }
        }
    }
    
    func resetAccountUI() {
        withAnimation {
            accounts = accounts.map { $0.resetUI() }
        }
    }
    
    func delete(at offsets: IndexSet) {
        let deletedAccounts = accounts.enumerated().filter { offsets.contains($0.offset) }.map { $0.element }
        deletedAccounts.forEach {
            try? AccountManager.shared.delete(account: $0)
        }
        withAnimation {
            accounts.remove(atOffsets: offsets)
        }
        recomputeNotifications()
    }
    
    func recomputeNotifications() {
        let accounts = accounts
        Task.detached(priority: .high) {
            let interestingCodes = CodeGenerator.shared.generateCodes(accounts: accounts)
            NotificationScheduler.shared.cancelNotifications()
            interestingCodes.forEach {
                NotificationScheduler.shared.scheduleNotification(for: $0)
            }
            NotificationScheduler.shared.scheduleComebackNotifications(after: interestingCodes.last?.dateStarted)
        }
    }
}
