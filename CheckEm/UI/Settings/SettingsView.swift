//
//  SettingsView.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import LocalAuthentication
import SwiftUI
import UIKit

struct SettingsView: View {
    
    @AppStorage("sortMode") private var sortMode: SortMode = .rarity
    @State private var showBackupExporter = false
    
    enum SortMode: String {
        case rarity
        case type
    }
    
    var onAppear: () -> Void
    var onDisappear: () -> Void
    
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

                Section("Backup") {
                    Button("Export 2FA Backup", systemImage: "square.and.arrow.up") {
                        showBackupExporter = true
                    }
                }
            }
            .animation(.bouncy, value: sortMode)
            .navigationTitle("Settings")
            .onAppear {
                onAppear()
            }
            .onDisappear {
                onDisappear()
            }
        }
        .background {
            SecretsExporter(isPresented: $showBackupExporter,
                            defaultFilename: "CheckEm-2FA-Backup") {
                try KeychainManager.shared.fetchAccounts()
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
        RoundNumberSettingsView()
        NumbersSequencesSettingsView()
        ConstantsSettingsView()
    }
    
    private func segmentedPickerItem(for sortMode: SortMode) -> some View {
        Text(sortMode.rawValue.capitalized)
            .tag(sortMode)
    }
}

struct SecretsExporter: View {

    @Binding var isPresented: Bool
    let defaultFilename: String
    let records: @Sendable () throws -> [String]

    @State private var exportError = ""
    @State private var shareItem: SecretsShareItem?
    @State private var showExportError = false
    @State private var temporaryExportDirectory: URL?

    var body: some View {
        Color.clear
            .onChange(of: isPresented) { _, shouldExport in
                if shouldExport {
                    isPresented = false
                    authenticateAndExport()
                }
            }
            .sheet(item: $shareItem, onDismiss: removeTemporaryExport) { item in
                SecretsActivityView(item: item.url) {
                    shareItem = nil
                }
            }
            .alert("Unable to Export", isPresented: $showExportError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(exportError)
            }
            .onDisappear {
                removeTemporaryExport()
            }
    }

    private func authenticateAndExport() {
        Task { @MainActor in
            do {
                let context = LAContext()
                guard try await context.evaluatePolicy(
                    .deviceOwnerAuthentication,
                    localizedReason: "Export your 2FA secret keys"
                ) else { return }
                await exportBackup()
            } catch {
                guard !error.isAuthenticationCancellation else { return }
                exportError = error.localizedDescription
                showExportError = true
            }
        }
    }

    private func exportBackup() async {
        do {
            let fetchRecords = records
            let accountRecords = try await Task.detached(priority: .userInitiated) {
                try fetchRecords()
            }.value
            let accounts = accountRecords
                .compactMap(URL.init(string:))
                .filter { $0.scheme == "otpauth" && $0.host == "totp" }
                .map(\.absoluteString)

            guard !accounts.isEmpty else {
                exportError = "No 2FA accounts were found."
                showExportError = true
                return
            }

            let directory = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString, isDirectory: true)
            try FileManager.default.createDirectory(at: directory,
                                                    withIntermediateDirectories: true)

            let fileURL = directory.appendingPathComponent("\(defaultFilename).txt")
            try Data(accounts.joined(separator: "\n").utf8)
                .write(to: fileURL, options: [.atomic, .completeFileProtection])

            temporaryExportDirectory = directory
            shareItem = SecretsShareItem(url: fileURL)
        } catch {
            exportError = error.localizedDescription
            showExportError = true
        }
    }

    private func removeTemporaryExport() {
        shareItem = nil
        if let temporaryExportDirectory {
            try? FileManager.default.removeItem(at: temporaryExportDirectory)
            self.temporaryExportDirectory = nil
        }
    }
}

private struct SecretsShareItem: Identifiable {

    let id = UUID()
    let url: URL
}

private struct SecretsActivityView: UIViewControllerRepresentable {

    let item: URL
    let onComplete: () -> Void

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: [item], applicationActivities: nil)
        controller.completionWithItemsHandler = { _, _, _, _ in
            Task { @MainActor in
                onComplete()
            }
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}

struct UltraRareSettingsView: View {
    
    @AppStorage("sexts") private var sexts: Bool = true
    @AppStorage("count") private var count: Bool = true
    @AppStorage("hunderedThousands") private var hunderedThousands: Bool = true
    @AppStorage("units") private var units: Bool = true
    @AppStorage("mathematicalConstants") private var mathematicalConstants: Bool = true
    @AppStorage("physicalConstants") private var physicalConstants: Bool = true
    
    var body: some View {
        Section("Ultra-rare GETs") {
            SettingsToggle($sexts, title: "Sextuples", example: "e.g. 777777")
            SettingsToggle($count, title: "Counting sequence", example: "e.g. 123456")
            SettingsToggle($hunderedThousands, title: "Hundered thousands", example: "e.g. 300000")
            SettingsToggle($units, title: "Single-digit numbers", example: "e.g. 000001")
            SettingsToggle($mathematicalConstants, title: "Math Constants", example: "e.g. 314159 (pi = 3.14159)")
            SettingsToggle($physicalConstants, title: "Physics constants", example: "e.g. 299108 (c = 2.99x10⁸)")
        }
    }
}

struct RareSettingsView: View {
    
    @AppStorage("quints") private var quints: Bool = true
    @AppStorage("repeatedTwos") private var repeatedTwos: Bool = true
    @AppStorage("tens") private var tens: Bool = true
    @AppStorage("nearlyCounting") private var nearlyCounting: Bool = true
    
    var body: some View {
        Section("Rare GETs") {
            SettingsToggle($quints, title: "Quints", example: "e.g. 555556")
            SettingsToggle($repeatedTwos, title: "Repeated pairs", example: "e.g. 121212")
            SettingsToggle($tens, title: "Two-digit numbers", example: "e.g. 000028")
            SettingsToggle($nearlyCounting, title: "Near-sequences", example: "e.g. 123450")
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
    @AppStorage("nearlySextuples") private var nearlySextuples: Bool = false
    @AppStorage("quints") private var quints: Bool = true
    @AppStorage("quads") private var quads: Bool = false
    
    var body: some View {
        Section("Multi-number GETs") {
            SettingsToggle($sexts, title: "Sextuples", example: "e.g. 777777")
            SettingsToggle($quints, title: "Quints", example: "e.g. 555556")
            SettingsToggle($nearlySextuples, title: "Near-sextuples", example: "e.g. 101111")
            SettingsToggle($quads, title: "Quads", example: "e.g. 324444")
        }
    }
}

struct RoundNumberSettingsView: View {
    
    @AppStorage("hunderedThousands") private var hunderedThousands: Bool = true
    @AppStorage("units") private var units: Bool = true
    @AppStorage("tens") private var tens: Bool = true
    
    var body: some View {
        Section("Round Number GETs") {
            SettingsToggle($hunderedThousands, title: "Hundered thousands", example: "e.g. 300000")
            SettingsToggle($units, title: "Single-digit numbers", example: "e.g. 000001")
            SettingsToggle($tens, title: "Two-digit numbers", example: "e.g. 000028")
        }
    }
}

struct NumbersSequencesSettingsView: View {
    
    @AppStorage("count") private var count: Bool = true
    @AppStorage("nearlyCounting") private var nearlyCounting: Bool = true
    @AppStorage("repeatedTwos") private var repeatedTwos: Bool = true
    @AppStorage("repeatedThrees") private var repeatedThrees: Bool = false
    @AppStorage("palindrome") private var palindrome: Bool = false
    
    var body: some View {
        Section("Number Sequence GETs") {
            SettingsToggle($count, title: "Counting sequence", example: "e.g. 123456")
            SettingsToggle($nearlyCounting, title: "Near-sequences", example: "e.g. 123450")
            SettingsToggle($repeatedTwos, title: "Repeated pairs", example: "e.g. 121212")
            SettingsToggle($repeatedThrees, title: "Repeated threes", example: "e.g. 123123")
            SettingsToggle($palindrome, title: "Palindromes", example: "e.g. 123321")
        }
    }
}

struct ConstantsSettingsView: View {
    
    @AppStorage("mathematicalConstants") private var mathematicalConstants: Bool = true
    @AppStorage("physicalConstants") private var physicalConstants: Bool = true
    
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
    SettingsView(onAppear: { }, onDisappear: { })
}
