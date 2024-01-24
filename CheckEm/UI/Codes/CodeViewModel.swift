//
//  CodeViewModel.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import Foundation

@Observable
final class CodeViewModel {
    
    var currentCode: String = ""
    var dateString: String = ""
    var countdown: String = ""
    
    init() {
//        let interestingCodes = CodeGenerator.shared.generateCodes()
//        NotificationScheduler.shared.cancelNotifications()
//        interestingCodes.forEach {
//            NotificationScheduler.shared.scheduleNotification(for: $0)
//        }
    }
 
    func refresh() {
        let otp = CodeGenerator.shared.currentCode()
        currentCode = otp.code
        let date = Date()
        dateString = Formatters.shared.fullDateFormatter.string(from: date)
        countdown = "\(Int(date.timeLeftInThirtySeconds.rounded()))"
    }
}
