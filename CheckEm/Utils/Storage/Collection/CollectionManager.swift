//
//  CollectionManager.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 02/02/2024.
//

import Foundation

final class CollectionManager {
    
    static let shared = CollectionManager()
    
    private init() { }
    
    func fetchCollection() throws -> [CollectionItem] {
        let collection = try KeychainManager.shared.fetchCollection() ?? ""
        if !collection.isEmpty {
            print(collection)
            print()
        }
        return collection
            .split(separator: ",")
            .compactMap { CollectionItem(code: String($0)) }
    }
    
    func save(code: String) throws {
        try KeychainManager.shared.storeCollectionItem(code: code)
    }
    
    func deleteCollection() throws {
        try KeychainManager.shared.deleteCollection()
    }
}
