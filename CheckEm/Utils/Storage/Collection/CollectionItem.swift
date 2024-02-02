//
//  CollectionItem.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 02/02/2024.
//

import Foundation

struct CollectionItem: Hashable {
    
    let code: String
    let interestingness: Interestingness
    
    init?(code: String) {
        guard let interestingness = Interestingness(code: code, eligible: Set(Interestingness.allCases)) else {
            return nil
        }
        self.code = code
        self.interestingness = interestingness
    }
    
    static func ==(lhs: CollectionItem, rhs: CollectionItem) -> Bool {
        return lhs.interestingness == rhs.interestingness
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(interestingness)
    }
}
