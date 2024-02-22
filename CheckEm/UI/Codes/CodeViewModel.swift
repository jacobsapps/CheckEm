//
//  CodeViewModel.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import SwiftUI

@Observable
final class CodeViewModel {
    
    var calculationPercentage: String?
    var accounts: [Account] = []
    var collection: [CollectionItem] = []
    
    private var otpComputationTask: Task<Void, Never>?
    private var notificationSchedulingTask: Task<Void, Never>?
    
    #error("Profile launch time")
    @MainActor
    init() {
        timestamp("View model init")
        configureAccounts()
//        Task {
//            await MainActor.run {
                refresh()
//            }
//        }
    }
    
    @MainActor
    func onAppear() {
//        timestamp("On appear")
        configureAccounts()
        recomputeNotifications()
        if let collection = try? CollectionManager.shared.fetchCollection() {
            withAnimation {
                self.collection = Array(Set(collection))
            }
        }
    }
    
    private func configureAccounts() {
        guard let accounts = try? AccountManager.shared.fetchAccounts() else { return }
        withAnimation {
//            timestamp("Set accounts")
            self.accounts = accounts
        }
    }
    
    @MainActor
    func create(account: Account, url: URL) throws {
        guard !accounts.contains(where: { $0.name == account.name }) else { return }
        let orderIncrement = (accounts.map { $0.order }.max() ?? -1) + 1
        try AccountManager.shared.save(account: account, url: url, increment: orderIncrement)
        withAnimation {
            accounts.append(account.withOrder(orderIncrement))
        }
        recomputeNotifications()
    }
    
    /// Returns `true` if the codes rotate on this tick
    @MainActor
    func refresh() {
//        timestamp("Refresh accounts")
        let date = Date()
        let oldCodes = accounts.map { $0.code }
        let newAccounts = accounts.map { $0.refreshed(date: date) }
        let newCodes = newAccounts.map { $0.code }
        withAnimation {
            accounts = newAccounts
        }
        if newCodes != oldCodes {
            HapticEngine.shared.play(haptic: .refresh)
        }
    }
    
    func resetAccountUI() {
        withAnimation {
            accounts = accounts.map { $0.resetUI() }
        }
    }
    
    func delete(at offsets: IndexSet) {
        cancelComputation()
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
        guard !accounts.isEmpty else { return }
        withAnimation {
            calculationPercentage = "0%"
        }
        handleNotificationScheduling()
        handleOTPComputation()
    }
    
    func cancelComputation() {
        calculationPercentage = nil
        notificationSchedulingTask?.cancel()
        otpComputationTask?.cancel()
    }
    
    private func handleNotificationScheduling() {
        notificationSchedulingTask?.cancel()
        notificationSchedulingTask = Task.detached(priority: .high) {
            guard await NotificationScheduler.shared.isAuthorized() else { return }
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
            guard await NotificationScheduler.shared.isAuthorized() else { return }
            let lastCodeDate = CodeGenerator.shared.generateCodes(accounts: accounts)
            try? await NotificationScheduler.shared.scheduleComebackNotifications(after: lastCodeDate)
            try? await Task.sleep(nanoseconds: 700_000_000)
            await MainActor.run { [weak self] in
                guard let self else { return }
                withAnimation {
                    self.calculationPercentage = nil
                }
            }
        }
    }
}
