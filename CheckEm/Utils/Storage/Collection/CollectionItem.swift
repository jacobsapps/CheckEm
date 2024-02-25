//
//  CollectionItem.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 02/02/2024.
//

import Foundation

extension [CollectionItem] {
    
    var groupedByInterestingness: [Interestingness: [String]] {
        reduce(into: [Interestingness: [String]]()) {
            if let existingCodes = $0[$1.interestingness] {
                $0[$1.interestingness] = existingCodes + CollectionOfOne($1.code)
            } else {
                $0[$1.interestingness] = [$1.code]
            }
        }
    }
}

struct CollectionItem: Equatable, Hashable {
    
    let code: String
    let interestingness: Interestingness
    
    init?(code: String) {
        guard let interestingness = Interestingness(code: code, eligible: Set(Interestingness.allCases)) else {
            return nil
        }
        self.code = code
        self.interestingness = interestingness
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(interestingness)
    }
}

extension [CollectionItem] {
    
    var ultraRares: [CollectionItem] {
        let types: Set<Interestingness> = [.counting,
                                           .sexts,
                                           .units,
                                           .hunderedThousands]
        return filter { item in types.contains(where: { $0 == item.interestingness }) }
    }
    
    var rares: [CollectionItem] {
        let types: Set<Interestingness> = [.quints,
                                           .tens,
                                           .repeatedTwos]
        
        return filter { item in types.contains(where: { $0 == item.interestingness }) }
    }
    
    var mathsConstants: [CollectionItem] {
        let types: Set<Interestingness> = [.pi,
                                           .e,
                                           .phi,
                                           .rootTwo,
                                           .aperysConstant,
                                           .eulersConstant]
        return filter { item in types.contains(where: { $0 == item.interestingness }) }
    }
    
    var physicsConstants: [CollectionItem] {
        let types: Set<Interestingness> = [.speedOfLight,
                                           .planksConstant,
                                           .avogadrosConstant,
                                           .gravitationalConstant,
                                           .boltzmannConstant,
                                           .fineStructureConstant,
                                           .vacuumPermittivity,
                                           .charge]
        return filter { item in types.contains(where: { $0 == item.interestingness }) }
    }
    
    var commons: [CollectionItem] {
        let types: Set<Interestingness> = [.palindrome,
                                           .repeatedThrees,
                                           .nearlySextuples,
                                           .quads]
        return filter { item in types.contains(where: { $0 == item.interestingness }) }
    }
}
