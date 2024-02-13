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

struct CodeView: View {
    
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
            .onReceive(timer) { _ in
                let didChange = viewModel.refresh()
                if didChange {
                    HapticEngine.shared.play(haptic: .refresh)
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
                    Task {
                        try? await NotificationScheduler.shared.requestAuthorization()
                        viewModel.recomputeNotifications()
                        if !requestedAppReviewSettings {
                            requestReview()
                            requestedAppReviewSettings = true
                        }
                    }
                })
            }
            .sheet(isPresented: $showCollection) {
                CollectionItemsView(collection: viewModel.collection) {
                    Task {
                        try? await NotificationScheduler.shared.requestAuthorization()
                        if !requestedAppReviewCollection {
                            requestReview()
                            requestedAppReviewCollection = true
                        }
                    }
                }
            }
        }
        .onAppear {
            refreshUI()
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
