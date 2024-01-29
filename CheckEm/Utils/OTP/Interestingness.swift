//
//  Interestingness.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import Foundation

enum Interestingness {
    
    case sexts
    case counting
    case pi
    case e
    case phi
    case speedOfLight
    case planksConstant
    case charge
    case quints
    case palindrome
    case repeated
    case nearlySextuples
    case quads
    
    init?(code: String, eligible: Set<Interestingness>) {
        if eligible.contains(.sexts) && code.checkThoseSexts() {
            self = .sexts
        } else if eligible.contains(.counting) && code.checkThatCounting() {
            self = .counting
        } else if eligible.contains(.pi) && code == "314159" {
            self = .pi
        } else if eligible.contains(.e) && code == "271828" {
            self = .e
        } else if eligible.contains(.phi) && code == "161803" {
            self = .phi
        } else if eligible.contains(.speedOfLight) && code == "299792" {
            self = .speedOfLight
        } else if eligible.contains(.planksConstant) && code == "662607" {
            self = .planksConstant
        } else if eligible.contains(.charge) && code == "160218" {
            self = .charge
        } else if eligible.contains(.quints) && code.checkThoseQuints() {
            self = .quints
        } else if eligible.contains(.nearlySextuples) && code.checkThoseNearlySextuples() {
            self = .nearlySextuples
        } else if eligible.contains(.quads) && code.checkThoseQuads() {
            self = .quads
        } else if eligible.contains(.palindrome) && code.checkThatPalindrome() {
            self = .palindrome
        } else if eligible.contains(.repeated) && code.checkThoseRepeats() {
            self = .repeated
        } else {
            return nil
        }
    }
    
    var title: String {
        switch self {
        case .sexts: return "Sexts GET"
        case .counting: return "Sequential numbers GET"
        case .pi: return "π GET"
        case .e: return "e GET"
        case .phi: return "φ GET"
        case .speedOfLight: return "Speed of Light GET"
        case .planksConstant: return "Planck Constant GET"
        case .charge: return "Elementary Charge GET"
        case .quints: return "Quints GET"
        case .palindrome: return "Palindrome GET"
        case .repeated: return "Repeated sequence GET"
        case .nearlySextuples: return "Almost-sextuples GET"
        case .quads: return "Quads GET"
        }
    }
    
    func body(code: String) -> String {
        switch self {
        case .sexts: return "Check those sexts: \(code)"
        case .counting: return "Check that count: \(code)"
        case .pi: return "Check that pi: \(code)"
        case .e: return "Check that Euler's number: \(code)"
        case .phi: return "Check that Golden Ratio: \(code)"
        case .speedOfLight: return "Check that universal speed limit: \(code)"
        case .planksConstant: return "Check that quantum of action: \(code)"
        case .charge: return "Check that electron charge: \(code)"
        case .quints: return "Check those quints: \(code)"
        case .nearlySextuples: return "Check these nearly-sextuples: \(code)"
        case .palindrome: return "Check that symmetry: \(code)"
        case .repeated: return "Check this repeat: \(code)"
        case .quads: return "Check those quads: \(code)"
        }
    }
}

extension String {
    
    func checkThoseSexts() -> Bool {
        (try? /(\d)\1\1\1\1\1/.firstMatch(in: self)) != nil
    }
    
    func checkThoseQuints() -> Bool {
        (try? /(\d)\1\1\1\1/.firstMatch(in: self)) != nil
    }
    
    func checkThoseQuads() -> Bool {
        (try? /(\d)\1\1\1/.firstMatch(in: self)) != nil
    }
    
    func checkThatCounting() -> Bool {
        let characters = Array(self)
        for i in 1..<characters.count {
            if let prevDigit = Int(String(characters[i - 1])),
               let currentDigit = Int(String(characters[i])),
               currentDigit != prevDigit + 1 {
                return false
            }
        }
        return true
    }
    
    func checkThoseNearlySextuples() -> Bool {
        var digitCounts = [Character: Int]()
        forEach {
            digitCounts[$0, default: 0] += 1
        }
        return digitCounts.contains { $0.value == 5 }
    }
    
    func checkThatPalindrome() -> Bool {
        self == String(self.reversed())
    }
    
    func checkThoseRepeats() -> Bool {
        self.prefix(3) == self.suffix(3)
    }
}
