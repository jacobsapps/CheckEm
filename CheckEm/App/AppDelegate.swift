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
                                withCompletionHandler completionHandler: @escaping @Sendable () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        guard let deepLinkString = userInfo["deepLink"] as? String,
              let deepLinkURL = URL(string: deepLinkString),
              let code = deepLinkURL.code else {
            completionHandler()
            return
        }

        KeychainManager.accessQueue.async {
            try? CollectionManager.shared.save(code: code)
            completionHandler()
        }
    }
}
