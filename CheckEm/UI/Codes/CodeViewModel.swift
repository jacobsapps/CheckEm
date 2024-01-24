//
//  CodeViewModel.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import Foundation

@Observable
final class CodeViewModel {
    
    private var codeGenerator: CodeGenerator?
    
    var accountName: String = ""
    var currentCode: String = ""
    var dateString: String = ""
    var countdown: String = ""
    
    func create(account: Account) {
        accountName = account.name
        print(account.secret.base64EncodedString())
        codeGenerator = CodeGenerator(account: account)
        guard let codeGenerator else { return }
        let interestingCodes = codeGenerator.generateCodes()
        NotificationScheduler.shared.cancelNotifications()
        interestingCodes.forEach {
            NotificationScheduler.shared.scheduleNotification(for: $0)
        }
    }
 
    func refresh() {
        guard let codeGenerator else { return }
        let otp = codeGenerator.currentCode()
        currentCode = otp.code
        let date = Date()
        dateString = Formatters.shared.fullDateFormatter.string(from: date)
        countdown = "\(Int(date.timeLeftInThirtySeconds.rounded()))"
    }
}
