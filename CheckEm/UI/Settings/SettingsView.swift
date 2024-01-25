//
//  SettingsView.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("trips") private var trips: Bool = true
    @AppStorage("quads") private var quads: Bool = true
    @AppStorage("quints") private var quints: Bool = true
    @AppStorage("sexts") private var sexts: Bool = true
    
    var body: some View {
        NavigationStack {
            List {
                Section("Repeated numbers") {
                    Toggle(isOn: $trips, label: {
                        Text("Trips")
                            .font(.body)
                        
                        Text("e.g. 012666")
                            .font(.caption)
                    })
                    
                    Toggle(isOn: $quads, label: {
                        Text("Quads")
                            .font(.body)
                        
                        Text("e.g. 014444")
                            .font(.caption)
                    })
                    
                    Toggle(isOn: $quints, label: {
                        Text("Quints")
                            .font(.body)
                        
                        Text("e.g. 755555")
                            .font(.caption)
                    })
                    
                    Toggle(isOn: $sexts, label: {
                        Text("Sexts")
                            .font(.body)
                        
                        Text("e.g. 777777")
                            .font(.caption)
                    })
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
