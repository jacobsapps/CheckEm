//
//  CollectionItemsView.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 02/02/2024.
//

import SwiftUI

struct CollectionItemsView: View {
    
    let collection: [CollectionItem]
    var onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            List {
                CollectionSection(title: "Ultra rare", collection: collection.ultraRares)
                CollectionSection(title: "Maths constants", collection: collection.mathsConstants)
                CollectionSection(title: "Physics constants", collection: collection.physicsConstants)
                CollectionSection(title: "Rare", collection: collection.rares)
                CollectionSection(title: "Common", collection: collection.commons)
            }
            .navigationTitle("Collection")
            .onDisappear {
                onDismiss()
            }
        }
    }
}

struct CollectionSection: View {
    
    let title: String
    let collection: [CollectionItem]
    
    var body: some View {
        Section(title) {
            if collection.isEmpty {
                emptyListItem
                
            } else {
                ForEach(collection, id: \.interestingness) {
                    collectionItem($0)
                }
            }
        }
    }
    
    private func collectionItem(_ item: CollectionItem) -> some View {
        HStack {
            VStack {
                Text(item.interestingness.title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(item.interestingness.body(code: item.code))
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Image(systemName: "checkmark.seal.fill")
                .font(.title2)
                .foregroundStyle(.green)
        }
    }
    
    private var emptyListItem: some View {
        HStack {
            Text("No \(title) GETs found")
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Image(systemName: "checkmark.seal")
                .font(.title2)
                .foregroundStyle(.gray)
        }
    }
}
