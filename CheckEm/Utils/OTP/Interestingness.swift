//
//  Interestingness.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import Foundation

enum Interestingness {
    
    case sexts
    case quints
    case quads
    case trips
    
    init?(code: String) {
        if code.checkThoseSexts() {
            self = .sexts
        } else if code.checkThoseQuints() {
            self = .quints
        } else if code.checkThoseQuads() {
            self = .quads
//        } else if code.checkThoseTrips() {
//            self = .trips
        } else {
            return nil
        }
    }
    
    var title: String {
        switch self {
        case .sexts: return "Sexts GET!!!"
        case .quints: return "Quints GET!!"
        case .quads: return "Quads GET!"
        case .trips: return "Trips GET"
        }
    }
    
    func body(code: String) -> String {
        switch self {
        case .sexts: return "Check those sexts: \(code)"
        case .quints: return "Check those quints: \(code)"
        case .quads: return "Check those quads: \(code)"
        case .trips: return "Check those trips: \(code)"
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
    
    func checkThoseTrips() -> Bool {
        (try? /(\d)\1\1/.firstMatch(in: self)) != nil
    }
}
