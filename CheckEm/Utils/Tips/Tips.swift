//
//  Tips.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 12/02/2024.
//

import Foundation
import TipKit

struct QRTip: Tip {
    
    var title: Text {
        Text("Scan a QR code to get started")
    }
    
    var image: Image? {
        Image(systemName: "qrcode")
    }
    
    var message: Text? {
        Text("This app securely generates 2FA codes to log into your accounts")
    }
}

struct SettingsTip: Tip {
    
    var title: Text {
        Text("Choose the patterns you like")
    }
    
    var image: Image? {
        Image(systemName: "gear")
    }
    
    var message: Text? {
        Text("Get notifications when numbers like 000000, 123456, or 314159 show up")
    }
}

struct CollectionTip: Tip {
    
    var title: Text {
        Text("Collect rare GETs")
    }
    
    var image: Image? {
        Image(systemName: "checkmark.seal")
    }
    
    var message: Text? {
        Text("Tap the notification to store it in your collection")
    }
}
