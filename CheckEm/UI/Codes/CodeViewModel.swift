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
        guard let accounts = try? DatabaseManager.shared.getAccounts() else { return }
        self.accounts = accounts
        regenerateNotifications()
    }
    
    @MainActor
    func create(account: Account) {
        try? DatabaseManager.shared.save(account: account)
        regenerateNotifications()
    }
    
    func refresh() {
//        guard let codeGenerator,
//            let otp = codeGenerator.currentCode() else { return }
//        currentCode = otp.code
//        let date = Date()
//        dateString = Formatters.shared.fullDateFormatter.string(from: date)
//        countdown = "\(Int(date.timeLeftInThirtySeconds.rounded()))"
    }
    
    func delete(at offsets: IndexSet) {
        let deletedAccounts = accounts.enumerated().filter { offsets.contains($0.offset) }.map { $0.element }
        deletedAccounts.forEach {
            KeychainManager.fetchSecret(<#T##self: KeychainManager##KeychainManager#>)
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
