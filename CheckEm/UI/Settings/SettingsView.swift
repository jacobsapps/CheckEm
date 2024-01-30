//
//  SettingsView.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("sortMode") private var sortMode: SortMode = .rarity
    
    enum SortMode: String {
        case rarity
        case type
    }
    
    var recomputeNotifications: () -> Void
    
    var body: some View {
        NavigationStack {
            List {
                Text("Select which types of numbers you want to recieve in push notifications")
                    .font(.body)
                
                Picker("Sort Mode", selection: $sortMode) {
                    segmentedPickerItem(for: .rarity)
                    segmentedPickerItem(for: .type)
                }
                .pickerStyle(.segmented)
                
                settingsViewForSortMode
            }
            .animation(.bouncy, value: sortMode)
            .navigationTitle("Settings")
            .onDisappear {
                recomputeNotifications()
            }
        }
    }
    
    @ViewBuilder
    var settingsViewForSortMode: some View {
        switch sortMode {
        case .rarity:
            raritySortedView
        case .type:
            typeSortedView
        }
    }
    
    @ViewBuilder
    private var raritySortedView: some View {
        UltraRareSettingsView()
        RareSettingsView()
        CommonSettingsView()
    }
    
    @ViewBuilder
    private var typeSortedView: some View {
        RepeatedNumbersSettingsView()
        NumbersSequencesSettingsView()
        ConstantsSettingsView()
    }
    
    private func segmentedPickerItem(for sortMode: SortMode) -> some View {
        Text(sortMode.rawValue.capitalized)
            .tag(sortMode)
    }
}

struct UltraRareSettingsView: View {
    
    @AppStorage("sexts") private var sexts: Bool = true
    @AppStorage("count") private var count: Bool = true
    @AppStorage("mathematicalConstants") private var mathematicalConstants: Bool = true
    @AppStorage("physicalConstants") private var physicalConstants: Bool = false
    
    var body: some View {
        Section("Ultra-rare GETs") {
            SettingsToggle($sexts, title: "Sexts", example: "e.g. 777777")
            SettingsToggle($count, title: "Counting sequence", example: "e.g. 123456")
            SettingsToggle($mathematicalConstants, title: "Math Constants", example: "e.g. 314159 (pi = 3.14159)")
            SettingsToggle($physicalConstants, title: "Physics constants", example: "e.g. 299108 (c = 2.99x10⁸)")
        }
    }
}

struct RareSettingsView: View {
    
    @AppStorage("quints") private var quints: Bool = true
    @AppStorage("repeatedTwos") private var repeatedTwos: Bool = true
    
    var body: some View {
        Section("Rare GETs") {
            SettingsToggle($quints, title: "Quints", example: "e.g. 555556")
            SettingsToggle($repeatedTwos, title: "Repeated pairs", example: "e.g. 121212")
        }
    }
}

struct CommonSettingsView: View {
    
    @AppStorage("nearlySextuples") private var nearlySextuples: Bool = false
    @AppStorage("palindrome") private var palindrome: Bool = false
    @AppStorage("repeatedThrees") private var repeatedThrees: Bool = false
    @AppStorage("quads") private var quads: Bool = false

    var body: some View {
        Section("Common GETs") {
            SettingsToggle($nearlySextuples, title: "Near-sextuples", example: "e.g. 101111")
            SettingsToggle($quads, title: "Quads", example: "e.g. 324444")
            SettingsToggle($palindrome, title: "Palindromes", example: "e.g. 123321")
            SettingsToggle($repeatedThrees, title: "Repeated threes", example: "e.g. 123123")
        }
    }
}

struct RepeatedNumbersSettingsView: View {
    
    @AppStorage("sexts") private var sexts: Bool = true
    @AppStorage("quints") private var quints: Bool = true
    @AppStorage("nearlySextuples") private var nearlySextuples: Bool = false
    @AppStorage("quads") private var quads: Bool = false
    
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
    @AppStorage("repeatedTwos") private var repeatedTwos: Bool = true
    @AppStorage("repeatedThrees") private var repeatedThrees: Bool = false
    @AppStorage("palindrome") private var palindrome: Bool = false
    
    var body: some View {
        Section("Number Sequence GETs") {
            SettingsToggle($count, title: "Counting sequence", example: "e.g. 123456")
            SettingsToggle($repeatedTwos, title: "Repeated pairs", example: "e.g. 121212")
            SettingsToggle($repeatedThrees, title: "Repeated threes", example: "e.g. 123123")
            SettingsToggle($palindrome, title: "Palindromes", example: "e.g. 123321")
        }
    }
}

struct ConstantsSettingsView: View {
    
    @AppStorage("mathematicalConstants") private var mathematicalConstants: Bool = true
    @AppStorage("physicalConstants") private var physicalConstants: Bool = false
    
    var body: some View {
        Section("Special number GETs") {
            SettingsToggle($mathematicalConstants, title: "Math Constants", example: "e.g. 314159 (pi = 3.14159)")
            SettingsToggle($physicalConstants, title: "Physics constants", example: "e.g. 299108 (c = 2.99x10⁸)")
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
