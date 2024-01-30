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
    
    private var otpComputationTask: Task<Void, Never>?
    private var notificationSchedulingTask: Task<Void, Never>?
    
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
