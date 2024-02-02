//
//  CodeView.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import Combine
import StoreKit
import SwiftUI

// High priority -
// TODO: - Haptic buzz on refresh
// TODO: - Create a "collection" screen using deep links - collecting the seen GETs as stored items (with a dictionary on the keychain)
// TODO: - Cancel processing tasks when opening Settings view
// TODO: - Add ordering as a query item to the stored URL in the keychain
// TODO: - Push notification deep links to an app review prompt, when the GET is still present - https://www.avanderlee.com/swiftui/deeplink-url-handling/
// TODO: - Bug - Progress view doesn't appear on the second load
// TODO: - Bug - Ignore scanned duplicates in the view model accounts - don't append scans to accounts if it's already there
// TODO: - Bug - There's a bug where the percentage fluctuates up and down when there are 2 concurrent calculations
// TODO: - Add TipKit to QR and Settings
// TODO: - StoreKit; pay £5 to get it free forever
// TODO: - Implement a hard limit on monthly notifications for non-customers

// Low priority -
// TODO: - Use @SceneStorage for state restoration; so we aren't waiting ages for the keychain operations
// TODO: - Look back/forward one code (maybe don't do this)

struct CodeView: View {
    
    @Environment(\.requestReview) var requestReview
    @AppStorage("numberOfAccounts") private var numberOfAccounts: Int = 0
    @AppStorage("requestedAppReviewSettings") var requestedAppReviewSettings: Bool = false
    @State private var showScanner: Bool = false
    @State private var showSettings: Bool = false
    @State private var showCollection: Bool = false
    @State private var viewModel = CodeViewModel()
    @State private var timer = Timer.publish(every: 1, tolerance: 0, on: .current, in: .common).autoconnect()
    @State private var searchText: String = ""
    @State private var hapticTrigger: Bool = false

    private var accountSearchResults: [Account] {
        if searchText.isEmpty {
            return viewModel.accounts
            
        } else {
            return viewModel.accounts.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                accountListContent
                loadingIndicator
            }
            .searchable(text: $searchText,
                        placement: .automatic,
                        prompt: "Search")
            .onReceive(timer) { _ in
                let didChange = viewModel.refresh()
                if didChange {
                    hapticTrigger.toggle()
                }
            }
            .navigationTitle("Check 'em")
            .toolbar { toolbarView }
            .sheet(isPresented: $showScanner) {
                ScanView {
                    showScanner = false
                    try? viewModel.create(account: $0, url: $1)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView {
                    viewModel.recomputeNotifications()
                    if !requestedAppReviewSettings {
                        requestReview()
                        requestedAppReviewSettings = true
                    }
                }
            }
            .sheet(isPresented: $showCollection) {
                CollectionItemsView(collection: viewModel.collection)
            }
        }
        .task {
            await viewModel.task()
            numberOfAccounts = viewModel.accounts.count
        }
        .onAppear {
            viewModel.resetAccountUI()
        }
    }
    
    @ViewBuilder
    private var accountListContent: some View {
        if viewModel.accounts.isEmpty {
            emptyAccountsView
            
        } else {
            ForEach(accountSearchResults, id: \.name) { account in
                AccountView(account: account)
                    .onDisappear {
                        numberOfAccounts = viewModel.accounts.count
                    }
            }
            .onDelete(perform: viewModel.delete)
            .sensoryFeedback(.levelChange, trigger: hapticTrigger)
        }
    }
    
    private var emptyAccountsView: some View {
        ForEach((0..<numberOfAccounts), id: \.self) { _ in
            Section(" ") {
                HStack {
                    Text(" ")
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ProgressView()
                }
            }
        }
    }
    
    @ViewBuilder
    private var loadingIndicator: some View {
        if viewModel.isCalculatingOTPs {
            HStack(spacing: 8) {
                Text("Processing your numbers...")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(viewModel.calculationPercentage)
                    .font(.body)
                    .fontWeight(.medium)
                
                ProgressView()
                    .tint(.green)
            }
        }
    }
    
    @ViewBuilder
    private var toolbarView: some View {
        if !viewModel.collection.isEmpty {
            Button(action: {
                showCollection.toggle()
            }, label: {
                Image(systemName: "checkmark.seal")
            })
        }
        Button(action: {
            showScanner.toggle()
        }, label: {
            Image(systemName: "qrcode")
        })
        Button(action: {
            showSettings.toggle()
        }, label: {
            Image(systemName: "gear")
        })
    }
}

#Preview {
    CodeView()
}
