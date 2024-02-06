//
//  CodeViewModel.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import SwiftUI

@Observable
final class CodeViewModel {
    
    var isCalculatingOTPs: Bool = false
    var calculationPercentage: String = ""
    var accounts: [Account] = []
    var collection: [CollectionItem] = []
    
    private var otpComputationTask: Task<Void, Never>?
    private var notificationSchedulingTask: Task<Void, Never>?
    
    @MainActor
    func onAppear() {
        guard let accounts = try? AccountManager.shared.fetchAccounts() else { return }
        withAnimation {
            self.accounts = accounts
        }
        recomputeNotifications()
        if let collection = try? CollectionManager.shared.fetchCollection() {
            withAnimation {
                self.collection = collection
            }
        }
    }
    
    @MainActor
    func create(account: Account, url: URL) throws {
        let accountIncrement = accounts.last?.order ?? 0
        try AccountManager.shared.save(account: account, url: url, increment: accountIncrement)
        withAnimation {
            accounts.append(account)
        }
        recomputeNotifications()
    }
    
    /// Returns `true` if the codes rotate on this tick
    @MainActor
    func refresh() -> Bool {
        let date = Date()
        let oldCodes = accounts.map { $0.code }
        let newAccounts = accounts.map { $0.refreshed(date: date) }
        let newCodes = newAccounts.map { $0.code }
        withAnimation {
            accounts = newAccounts
        }
        return newCodes != oldCodes
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
        withAnimation {
            isCalculatingOTPs = true
            calculationPercentage = "0%"
        }
        handleNotificationScheduling()
        handleOTPComputation()
    }
    
    private func handleNotificationScheduling() {
        notificationSchedulingTask?.cancel()
        notificationSchedulingTask = Task.detached(priority: .high) {
            NotificationScheduler.shared.cancelNotifications()
            for await (code, count) in CodeGenerator.shared.codeSubject.values {
                try? await NotificationScheduler.shared.scheduleNotification(for: code)
                let completionPercentage = Int(100*Double(count)/Double(CodeGenerator.Constants.localNotificationLimit - 2).rounded(.up))
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    withAnimation {
                        self.calculationPercentage = "\(completionPercentage)%"
                    }
                }
            }
        }
    }
    
    private func handleOTPComputation() {
        let accounts = accounts
        otpComputationTask?.cancel()
        otpComputationTask = Task.detached(priority: .high) {
            try? await NotificationScheduler.shared.requestAuthorization()
            let lastCodeDate = CodeGenerator.shared.generateCodes(accounts: accounts)
            try? await NotificationScheduler.shared.scheduleComebackNotifications(after: lastCodeDate)
            try? await Task.sleep(nanoseconds: 700_000_000)
            await MainActor.run { [weak self] in
                guard let self else { return }
                withAnimation {
                    self.isCalculatingOTPs = false
                }
            }
        }
    }
}
