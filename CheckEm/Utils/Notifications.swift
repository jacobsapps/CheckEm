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
    
    func scheduleNotification(for otp: OTP) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                self.createNotification(for: otp)
            } else {
                print("Permission not granted")
            }
        }
    }

    private func createNotification(for otp: OTP) {
        
        guard let interestingness = otp.interestingness else { return }
        
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = interestingness.title
        content.body = interestingness.body(code: otp.code)
        content.sound = UNNotificationSound.default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: otp.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        center.add(request) { (error) in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Scheduled \(otp.code) at \(otp.date)")
            }
        }
    }
}
