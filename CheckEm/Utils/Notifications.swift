//
//  Notifications.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import UserNotifications

final class NotificationScheduler {
    
    static let shared = NotificationScheduler()
    
    private init() { }
    
    func cancelNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
    func isAuthorized() async -> Bool {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus == .authorized
    }
    
    func scheduleNotification(for otp: OTP) async throws {
        let center = UNUserNotificationCenter.current()
        try await center.requestAuthorization(options: [.alert, .sound])
        createNotification(for: otp)
    }
    
    func requestAuthorization() async throws {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge])
    }
    
    func scheduleComebackNotifications(after date: Date?) async throws {
        guard let date else { return }
        let center = UNUserNotificationCenter.current()
        try await center.requestAuthorization(options: [.alert, .sound])
        comebackNotification(at: date.addingTimeInterval(10))
        comebackNotification(at: date.addingTimeInterval(60 * 60 * 24 * 3))
    }
    
    private func createNotification(for otp: OTP) {
        
        guard let interestingness = otp.interestingness else { return }
        
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = interestingness.title
        content.body = interestingness.body(code: otp.code)
        content.sound = UNNotificationSound.default
        content.userInfo = ["deepLink": "checkem://\(otp.code)"]
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: otp.dateStarted)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if let error = error {
                efficientPrint("Error scheduling notification: \(error)")
            } else {
                efficientPrint("Scheduled \(interestingness): \(otp.code) @ \(otp.dateStarted)")
            }
        }
    }
    
    private func comebackNotification(at date: Date) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Check 'em again"
        content.body = "Come back to the app so we can re-schedule notifications"
        content.sound = UNNotificationSound.default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if let error = error {
                efficientPrint("Error scheduling notification: \(error)")
            } else {
                efficientPrint("Scheduled comeback at \(date)")
            }
        }
    }
}

private func efficientPrint(_ string: String) {
    #if DEBUG
    print(string)
    #endif
}
