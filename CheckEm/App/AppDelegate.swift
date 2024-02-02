//
//  AppDelegate.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 02/02/2024.
//

import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let deepLinkString = userInfo["deepLink"] as? String,
           let deepLinkURL = URL(string: deepLinkString) {
            print(deepLinkURL)
            print()
            guard let code = deepLinkURL.code else { return }
            try? CollectionManager.shared.save(code: code)
        }
        
        completionHandler()
    }
}
