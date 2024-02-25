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
                CollectionSection(title: "Ultra rare",
                                  collection: collection.ultraRares.groupedByInterestingness)
                CollectionSection(title: "Maths constants",
                                  collection: collection.mathsConstants.groupedByInterestingness)
                CollectionSection(title: "Physics constants",
                                  collection: collection.physicsConstants.groupedByInterestingness)
                CollectionSection(title: "Rare",
                                  collection: collection.rares.groupedByInterestingness)
                CollectionSection(title: "Common",
                                  collection: collection.commons.groupedByInterestingness)
            }
            .navigationTitle("Collection")
            .onDisappear {
                onDismiss()
            }
        }
    }
}

struct CollectionSection: View {
    
    @ScaledMetric(relativeTo: .caption) var dividerHeight: CGFloat = 10

    let title: String
    let collection: [Interestingness: [String]]
    
    var body: some View {
        Section(title) {
            if collection.isEmpty {
                emptyListItem
                
            } else {
                ForEach(Array(collection.keys.sorted()), id: \.self) {
                    collectionItem(interestingness: $0, codes: collection[$0])
                }
            }
        }
    }
    
    private func collectionItem(interestingness: Interestingness, codes: [String]?) -> some View {
        HStack {
            VStack(spacing: .zero) {
                Text(interestingness.title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(interestingness.body(code: ""))
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(Set(codes ?? [])), id: \.self) {
                            Text($0)
                                .font(.caption)
                            
                            Divider()
                                .frame(height: dividerHeight)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                    }
                }
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
