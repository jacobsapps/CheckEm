//
//  CheckEmApp.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import SwiftUI
import TipKit

@main
struct CheckEmApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        timestamp("App init")
        try? Tips.configure()
        initializeDefaults()
    }
    
    var body: some Scene {
        WindowGroup {
            CodeView()
        }
    }
    
    func initializeDefaults() {
//        let url = URL(string: "otpauth://totp/Google%20-%20test%40gmail.com?secret=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA&issuer=google")!
//        try! KeychainManager.shared.storeAccount(named: "Google", url: url)
        CodeGenerator.shared.initializeDefaultsIfRequired()
    }
}

func timestamp(_ label: String) {
    let dateString = Formatters.shared.timestamp.string(from: Date())
    efficientPrint("\(dateString) - \(label)")
}
