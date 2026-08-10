//
//  CodeIncrementer.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 25/02/2024.
//

import Foundation
import Synchronization

final class CodeIncrementer: Sendable {

    private struct State {
        var codes: Int = 0
        var lastCodeDate: Date?
        var increment: Int = 0
    }

    private let state = Mutex(State())

    var codes: Int { get async { state.withLock { $0.codes } } }
    var lastCodeDate: Date? { get async { state.withLock { $0.lastCodeDate } } }

    func increment() async -> Int {
        state.withLock { state in
            defer { state.increment += 1 }
            return state.increment
        }
    }

    func newCodeFound(at date: Date) async -> Bool {
        state.withLock {
            guard $0.codes < CodeGenerator.Constants.localNotificationLimit - 2 else { return false }
            $0.codes += 1
            $0.lastCodeDate = date
            return true
        }
    }
}
