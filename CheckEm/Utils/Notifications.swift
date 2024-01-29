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
        center.requestAuthorization(options: [.alert, .sound]) { [weak self] granted, error in
            guard granted,
                  let self else { return }
            self.createNotification(for: otp)
        }
    }
    
    func scheduleComebackNotifications(after date: Date?) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { [weak self] granted, error in
            guard granted,
                  let date,
                  let self else { return }
            self.comebackNotification(at: date.addingTimeInterval(10))
            self.comebackNotification(at: date.addingTimeInterval(60 * 60 * 24 * 3))
        }
    }
    
    private func createNotification(for otp: OTP) {
        
        guard let interestingness = otp.interestingness else { return }
        
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = interestingness.title
        content.body = interestingness.body(code: otp.code)
        content.sound = UNNotificationSound.default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: otp.dateStarted)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Scheduled \(otp.code) at \(otp.dateStarted)")
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
                print("Error scheduling notification: \(error)")
            } else {
                print("Scheduled comeback at \(date)")
            }
        }
    }
}
