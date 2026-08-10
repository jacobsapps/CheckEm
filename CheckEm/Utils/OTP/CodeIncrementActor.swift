//
//  CodeIncrementActor.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 25/02/2024.
//

import Foundation

actor CodeIncrementActor {
    
    var codes: Int = 0
    var lastCodeDate: Date?
    private var _increment: Int = 0
    
    func increment() -> Int {
        defer { _increment += 1 }
        return _increment
    }
    
    func newCodeFound(at date: Date) -> Bool {
        guard codes < CodeGenerator.Constants.localNotificationLimit - 2 else { return false }
        codes += 1
        lastCodeDate = date
        return true
    }
}
