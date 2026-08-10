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
    
    init() {
        configureAccounts()
        refresh()
    }
    
    @MainActor
    func onAppear() {
        configureAccounts()
        refresh()
        recomputeNotifications()
        if let collection = try? CollectionManager.shared.fetchCollection() {
            withAnimation {
                self.collection = collection
            }
        }
    }
    
    private func configureAccounts() {
        guard let accounts = try? AccountManager.shared.fetchAccounts() else { return }
        guard self.accounts != accounts else { return }
        withAnimation {
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
    
    func refresh() {
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
    
    func delete(account: Account) {
        cancelComputation()
        try? AccountManager.shared.delete(account: account)
        withAnimation {
            accounts.removeAll { $0.name == account.name }
        }
        if accounts.isEmpty {
            NotificationScheduler.shared.cancelNotifications()
        } else {
            recomputeNotifications()
        }
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
            var codeCount = 0
            for await code in CodeGenerator.shared.codeSubject.values {
                codeCount += 1
                try? await NotificationScheduler.shared.scheduleNotification(for: code)
                let completionPercentage = Int(100 * (Double(codeCount) / Double(CodeGenerator.Constants.localNotificationLimit - 2).rounded(.up)))
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    withAnimation {
                        self.calculationPercentage = "\(min(100, completionPercentage))%"
                    }
                }
            }
        }
    }
    
    private func handleOTPComputation() {
        let accounts = accounts
        otpComputationTask?.cancel()
        otpComputationTask = Task.detached(priority: .high) {
            let incrementor = CodeIncrementer()
            guard await NotificationScheduler.shared.isAuthorized() else { return }
            await withTaskGroup(of: Void.self) { group in
                (0..<CodeGenerator.Constants.availableBackgroundCores).forEach { startingIncrement in
                    group.addTask {
                        await CodeGenerator.shared.generateCodes(accounts: accounts, incrementor: incrementor)
                    }
                }
            }
            try? await NotificationScheduler.shared.scheduleComebackNotifications(after: await incrementor.lastCodeDate)
            await MainActor.run { [weak self] in
                withAnimation {
                    self?.calculationPercentage = "100%"
                }
            }
            try? await Task.sleep(nanoseconds: 700_000_000)
            await MainActor.run { [weak self] in
                withAnimation {
                    self?.calculationPercentage = nil
                }
            }
        }
    }
}
