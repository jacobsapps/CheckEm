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
    
    init?(code: String) {
        if code.checkThoseSexts() {
            self = .sexts
        } else if code.checkThoseQuints() {
            self = .quints
        } else if code.checkThoseQuads() {
            self = .quads
        } else {
            return nil
        }
    }
    
    var title: String {
        switch self {
        case .sexts: return "Sexts GET!!!"
        case .quints: return "Quints GET!!"
        case .quads: return "Quads GET!"
        }
    }
    
    func body(code: String) -> String {
        switch self {
        case .sexts: return "Check those sexts: \(code)"
        case .quints: return "Check those quints: \(code)"
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
}
