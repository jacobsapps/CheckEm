//
//  CodeView.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import Combine
import StoreKit
import SwiftUI
import TipKit

// High priority -
// TODO: - Bug - Ignore scanned duplicates in the view model accounts - don't append scans to accounts if it's already there
// TODO: - Bug - There's a bug where the percentage fluctuates up and down when there are 2 concurrent calculations
// TODO: - StoreKit; pay £5 to get it free forever
// TODO: - Implement a hard limit on monthly notifications for non-customers

struct CodeView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.requestReview) var requestReview
    @AppStorage("numberOfAccounts") private var numberOfAccounts: Int = 0
    @AppStorage("requestedAppReviewSettings") var requestedAppReviewSettings: Bool = false
    @AppStorage("requestedAppReviewCollection") var requestedAppReviewCollection: Bool = false
    @State private var showScanner: Bool = false
    @State private var showSettings: Bool = false
    @State private var showCollection: Bool = false
    @State private var viewModel = CodeViewModel()
    @State private var timer = Timer.publish(every: 1, tolerance: 0, on: .current, in: .common).autoconnect()
    @State private var searchText: String = ""
    @State private var hapticTrigger: Bool = false
    @ScaledMetric private var tipImageSize: CGFloat = 24
    
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
                tips
            }
            .searchable(text: $searchText,
                        placement: .automatic,
                        prompt: "Search")
            .refreshable {
                refreshUI()
            }
            .sensoryFeedback(.impact(flexibility: .solid, intensity: 1), trigger: hapticTrigger)
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
                SettingsView(onAppear: {
                    viewModel.cancelComputation()
                }, onDisappear: {
                    viewModel.recomputeNotifications()
                    if !requestedAppReviewSettings {
                        requestReview()
                        requestedAppReviewSettings = true
                    }
                })
            }
            .sheet(isPresented: $showCollection) {
                CollectionItemsView(collection: viewModel.collection) {
                    if !requestedAppReviewCollection {
                        requestReview()
                        requestedAppReviewCollection = true
                    }
                }
            }
        }
        .onAppear {
            refreshUI()
        }
        .onChange(of: scenePhase, initial: false) { newScenePhase, _ in
            switch newScenePhase {
            case .active:
                refreshUI()
                
            default: break
            }
        }
    }
    
    @MainActor
    private func refreshUI() {
        viewModel.onAppear()
        numberOfAccounts = viewModel.accounts.count
        viewModel.resetAccountUI()
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
        if !viewModel.accounts.isEmpty,
           let calculationPercentage = viewModel.calculationPercentage {
            HStack(spacing: 8) {
                Text("Processing your numbers...")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(calculationPercentage)
                    .font(.body)
                    .fontWeight(.medium)
            }
        }
    }
    
    @ViewBuilder
    private var tips: some View {
        TipView(QRTip()).tipImageSize(CGSize(width: tipImageSize, height: tipImageSize))
        TipView(SettingsTip()).tipImageSize(CGSize(width: tipImageSize, height: tipImageSize))
        TipView(CollectionTip()).tipImageSize(CGSize(width: tipImageSize, height: tipImageSize))
    }
    
    @ViewBuilder
    private var toolbarView: some View {
        Button(action: {
            showCollection.toggle()
        }, label: {
            Image(systemName: "checkmark.seal")
        })
        
        Button(action: {
            showSettings.toggle()
        }, label: {
            Image(systemName: "gear")
        })
        
        Button(action: {
            showScanner.toggle()
        }, label: {
            Image(systemName: "qrcode")
        })
    }
}

#Preview {
    CodeView()
}
