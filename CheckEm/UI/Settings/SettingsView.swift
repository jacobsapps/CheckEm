//
//  SettingsView.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import SwiftUI

struct SettingsView: View {
    
    var body: some View {
        NavigationStack {
            List {
                RepeatedNumbersSettingsView()
                
            }
            .navigationTitle("Settings")
            .presentationDragIndicator(.visible)
            .presentationDetents([.fraction(0.77)])
        }
    }
}

struct RepeatedNumbersSettingsView: View {
    
    @AppStorage("trips") private var trips: Bool = true
    @AppStorage("quads") private var quads: Bool = true
    @AppStorage("quints") private var quints: Bool = true
    @AppStorage("sexts") private var sexts: Bool = true
    
    var body: some View {
        Section("Repeated numbers") {
            SettingsToggle($trips, title: "Trips", example: "e.g. 012666")
            SettingsToggle($quads, title: "Quads", example: "e.g. 014444")
            SettingsToggle($quints, title: "Quints", example: "e.g. 755555")
            SettingsToggle($sexts, title: "Sexts", example: "e.g. 777777")
        }
    }
}

struct SettingsToggle: View {
    
    @Binding var toggle: Bool
    var title: String
    var example: String
    
    init(_ toggle: Binding<Bool>, title: String, example: String) {
        self._toggle = toggle
        self.title = title
        self.example = example
    }
    
    var body: some View {
        Toggle(isOn: $toggle) {
            Text(title)
                .font(.body)
            
            Text(example)
                .font(.caption)
        }
    }
}

#Preview {
    SettingsView()
}
