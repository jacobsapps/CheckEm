//
//  CollectionItemsView.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 02/02/2024.
//

import SwiftUI

struct CollectionItemsView: View {
    
    let collection: [CollectionItem]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(Set(collection)), id: \.interestingness) { item in
                    HStack {
                        Text(item.interestingness.title)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Image(systemName: "checkmark.seal.fill")
                            .font(.title3)
                            .foregroundStyle(.green)
                    }
                }
            }
            .navigationTitle("Collection")
        }
    }
}
