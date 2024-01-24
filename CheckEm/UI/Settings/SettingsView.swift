//
//  SettingsView.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("quads") private var quads: Bool = false
    @AppStorage("quints") private var quints: Bool = false
    @AppStorage("sexts") private var sexts: Bool = false
    
    var body: some View {
        List {
            Section("Repeated numbers") {
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
    }
}

#Preview {
    SettingsView()
}
