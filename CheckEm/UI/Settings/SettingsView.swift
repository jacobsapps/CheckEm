//
//  SettingsView.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import SwiftUI

struct SettingsView: View {
    
    var recomputeNotifications: () -> Void
    
    var body: some View {
        NavigationStack {
            List {
                RepeatedNumbersSettingsView()
                NumbersSequencesSettingsView()
                ConstantsSettingsView()
            }
            .navigationTitle("Settings")
            .onDisappear {
                recomputeNotifications()
            }
        }
    }
}

struct RepeatedNumbersSettingsView: View {
    
    @AppStorage("sexts") private var sexts: Bool = true
    @AppStorage("quints") private var quints: Bool = true
    @AppStorage("nearlySextuples") private var nearlySextuples: Bool = true
    @AppStorage("quads") private var quads: Bool = true

    var body: some View {
        Section("Multi-number GETs") {
            SettingsToggle($sexts, title: "Sexts", example: "e.g. 777777")
            SettingsToggle($quints, title: "Quints", example: "e.g. 555556")
            SettingsToggle($nearlySextuples, title: "Near-sextuples", example: "e.g. 101111")
            SettingsToggle($quads, title: "Quads", example: "e.g. 324444")
        }
    }
}

struct NumbersSequencesSettingsView: View {
    
    @AppStorage("count") private var count: Bool = true
    @AppStorage("palindrome") private var palindrome: Bool = true
    @AppStorage("repeated") private var repeated: Bool = true
    
    var body: some View {
        Section("Number Sequence GETs") {
            SettingsToggle($count, title: "Counting sequence", example: "e.g. 012345")
            SettingsToggle($palindrome, title: "Palindromes", example: "e.g. 123321")
            SettingsToggle($repeated, title: "Repeated numbers", example: "e.g. 123123")
        }
    }
}

struct ConstantsSettingsView: View {
    
    @AppStorage("mathematicalConstants") private var mathematicalConstants: Bool = true
    @AppStorage("physicalConstants") private var physicalConstants: Bool = true

    var body: some View {
        Section("Special number GETs") {
            SettingsToggle($mathematicalConstants, title: "Math Constants", example: "e.g. pi (314159)")
            SettingsToggle($physicalConstants, title: "Physics constants", example: "e.g. c (299792)")
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
    SettingsView { }
}
