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
        try? Tips.configure()
        initializeDefaults()
    }
    
    var body: some Scene {
        WindowGroup {
            CodeView()
        }
    }
    
    func initializeDefaults() {
        CodeGenerator.shared.initializeDefaultsIfRequired()
    }
}
