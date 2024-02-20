//
//  Interestingness.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import Foundation

enum Interestingness: String, CaseIterable {
    
    case counting
    case sexts
    case units
    case hunderedThousands
    case pi
    case e
    case phi
    case rootTwo
    case aperysConstant
    case eulersConstant
    case speedOfLight
    case planksConstant
    case avogadrosConstant
    case gravitationalConstant
    case boltzmannConstant
    case fineStructureConstant
    case vacuumPermittivity
    case charge
    case quints
    case nearlyCounting
    case tens
    case palindrome
    case repeatedTwos
    case repeatedThrees
    case nearlySextuples
    case quads

//#error("Precompule all 1 million codes and interestingnesses! As a dict! See if that's the bottleneck")
//#error("-> mention this, but then use instruments to confirm, might be the hashing that's more")
//    #error("Go through w/ instruments and find the bottlenecks, it's probably one of these")
//    #error("Include reverseCounting!! Simply do code.reversed().checkThatCounting()")

    init?(code: String, eligible: Set<Interestingness>) {
        if eligible.contains(.counting) && code.checkThatCounting() {
            self = .counting
        } else if eligible.contains(.sexts) && code.checkThoseSexts() {
            self = .sexts
        } else if eligible.contains(.units) && code.checkThoseUnits() {
            self = .units
        } else if eligible.contains(.hunderedThousands) && code.checkThoseHunderedThousands() {
            self = .hunderedThousands
        } else if eligible.contains(.pi) && code == "314159" {
            self = .pi
        } else if eligible.contains(.e) && code == "271828" {
            self = .e
        } else if eligible.contains(.phi) && code == "161803" {
            self = .phi
        } else if eligible.contains(.rootTwo) && code == "141421" {
            self = .rootTwo
        } else if eligible.contains(.aperysConstant) && code == "120206" {
            self = .aperysConstant
        } else if eligible.contains(.eulersConstant) && code == "057722" {
            self = .eulersConstant
        } else if eligible.contains(.speedOfLight) && code == "299108" {
            self = .speedOfLight
        } else if eligible.contains(.planksConstant) && code == "661034" {
            self = .planksConstant
        } else if eligible.contains(.avogadrosConstant) && code == "601023" {
            self = .avogadrosConstant
        } else if eligible.contains(.gravitationalConstant) && code == "671011" {
            self = .gravitationalConstant
        } else if eligible.contains(.charge) && code == "161019" {
            self = .charge
        } else if eligible.contains(.boltzmannConstant) && code == "141023" {
            self = .boltzmannConstant
        } else if eligible.contains(.fineStructureConstant) && code == "000723" {
            self = .fineStructureConstant
        } else if eligible.contains(.vacuumPermittivity) && code == "891012" {
            self = .vacuumPermittivity
        } else if eligible.contains(.quints) && code.checkThoseQuints() {
            self = .quints
        } else if eligible.contains(.nearlyCounting) && code.checkThatNearlyCounting() {
            self = .nearlyCounting
        } else if eligible.contains(.repeatedTwos) && code.checkThoseRepeatedTwos() {
            self = .repeatedTwos
        } else if eligible.contains(.tens) && code.checkThoseTens() {
            self = .tens
        } else if eligible.contains(.palindrome) && code.checkThatPalindrome() {
            self = .palindrome
        } else if eligible.contains(.repeatedThrees) && code.checkThoseRepeatedThrees() {
            self = .repeatedThrees
        } else if eligible.contains(.nearlySextuples) && code.checkThoseNearlySextuples() {
            self = .nearlySextuples
        } else if eligible.contains(.quads) && code.checkThoseQuads() {
            self = .quads
        } else {
            return nil
        }
    }
    
    var title: String {
        switch self {
        case .sexts: return "Sextuples GET"
        case .counting: return "Sequential numbers GET"
        case .units: return "Single-digit GET"
        case .hunderedThousands: return "Six-figure GET"
        case .pi: return "π GET"
        case .e: return "e GET"
        case .phi: return "φ GET"
        case .rootTwo: return "√2 GET"
        case .aperysConstant: return "ζ(3) GET"
        case .eulersConstant: return "γ GET"
        case .speedOfLight: return "Speed of Light GET"
        case .planksConstant: return "Planck's Constant GET"
        case .avogadrosConstant: return "Avogadro's Constant GET"
        case .gravitationalConstant: return "Gravitational Constant GET"
        case .charge: return "Elementary Charge GET"
        case .boltzmannConstant: return "Boltzmann Constant GET"
        case .fineStructureConstant: return "Fine Structure Constant GET"
        case .vacuumPermittivity: return "Vacuum Permittivity GET"
        case .quints: return "Quints GET"
        case .nearlyCounting: return "Mostly-sequential GET"
        case .palindrome: return "Palindrome GET"
        case .repeatedTwos: return "Repeated twos GET"
        case .tens: return "Two-digit GET"
        case .repeatedThrees: return "Repeated threes GET"
        case .nearlySextuples: return "Almost-sextuples GET"
        case .quads: return "Quads GET"
        }
    }
    
    func body(code: String) -> String {
        switch self {
        case .sexts: return "Check those sexts: \(code)"
        case .counting: return "Check that counting: \(code)"
        case .units: return "Check that number: \(code)"
        case .hunderedThousands: return "Check that number: \(code)"
        case .pi: return "Check that pi: \(code)"
        case .e: return "Check that Euler's number: \(code)"
        case .phi: return "Check that Golden Ratio: \(code)"
        case .rootTwo: return "Check that square root (1.41421): \(code)"
        case .aperysConstant: return "Check that Apery's constant (1.20206): \(code)"
        case .eulersConstant: return "Check that Euler's constant (0.57722): \(code)"
        case .speedOfLight: return "Check that universal speed limit (2.99x10⁸): \(code)"
        case .planksConstant: return "Check that quantum of action (Pa): \(code)"
        case .avogadrosConstant: return "Check that mole of atoms (6.022x10²³): \(code)"
        case .gravitationalConstant: return "Check that Newtonian law (6.7x10⁻¹¹): \(code)"
        case .boltzmannConstant: return "Check that particle energy (1.380649×10⁻²³): \(code)"
        case .fineStructureConstant: return "Check that electromagnetic strength (0.00730): \(code)"
        case .vacuumPermittivity: return "Check that resistance to electric fields (8.854·10⁻¹²): \(code)"
        case .charge: return "Check that electron charge (1.6x10⁻¹⁹): \(code)"
        case .quints: return "Check those quints: \(code)"
        case .nearlyCounting: return "Check that counting: \(code)"
        case .tens: return "Check this number: \(code)"
        case .nearlySextuples: return "Check these nearly-sextuples: \(code)"
        case .palindrome: return "Check that symmetry: \(code)"
        case .repeatedTwos: return "Check this repeat: \(code)"
        case .repeatedThrees: return "Check this repeat: \(code)"
        case .quads: return "Check those quads: \(code)"
        }
    }
}

extension String {
    
    func checkThoseSexts() -> Bool {
        (try? /(\d)\1\1\1\1\1/.firstMatch(in: self)) != nil
    }
    
//    #error("This was the bottleneck, no longer!")
//    func checkThoseSexts() -> Bool {
//        (0...9).map {
//            String(repeating: String($0), count: 6)
//        }.contains(self)
//    }
    
//    func checkRepeatedDigits(count: Int) -> Bool {
//    self.contains { }
//        (0...9).map {
//            String(repeating: String($0), count: count)
//        }.contains(self)
//    }

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
    
    func checkThatNearlyCounting() -> Bool {
        let prefix = String(self.dropFirst())
        let suffix = String(self.dropLast())
        return prefix.checkThatCounting() || suffix.checkThatCounting()
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
    
    func checkThoseRepeatedThrees() -> Bool {
        self.prefix(3) == self.suffix(3)
    }
    
    func checkThoseRepeatedTwos() -> Bool {
        var copy = self
        let firstPair = (copy.removeFirst(), copy.removeFirst())
        let secondPair = (copy.removeFirst(), copy.removeFirst())
        let thirdPair = (copy.removeFirst(), copy.removeFirst())
        return (firstPair == secondPair) && (firstPair == thirdPair)
    }
    
    func checkThoseUnits() -> Bool {
        prefix(5) == "00000"
    }
    
    func checkThoseHunderedThousands() -> Bool {
        suffix(5) == "00000"
    }
    
    func checkThoseTens() -> Bool {
        prefix(4) == "0000"
    }
}
