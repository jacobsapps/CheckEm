//
//  CodeView.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import Combine
import StoreKit
import SwiftUI

struct CodeView: View {
    
    @Environment(\.requestReview) var requestReview
    @AppStorage("numberOfAccounts") private var numberOfAccounts: Int = 0
    @AppStorage("requestedAppReviewAccount") var requestedAppReviewAccount: Bool = false
    @AppStorage("requestedAppReviewSettings") var requestedAppReviewSettings: Bool = false
    @State private var showScanner: Bool = false
    @State private var showSettings: Bool = false
    @State private var viewModel = CodeViewModel()
    @State private var timer = Timer.publish(every: 1, tolerance: 0, on: .current, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            List {
                accountListContent
                loadingIndicator
            }
            .onReceive(timer) { _ in
                viewModel.refresh()
            }
            .navigationTitle("Check 'em")
            .toolbar { toolbarView }
            .sheet(isPresented: $showScanner) {
                ScanView {
                    showScanner = false
                    try? viewModel.create(account: $0, url: $1)
                    if !requestedAppReviewAccount {
                        requestedAppReviewAccount = true
                        requestReview()
                    }
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
            .task {
                await viewModel.task()
                numberOfAccounts = viewModel.accounts.count
            }
            .onAppear {
                viewModel.resetAccountUI()
            }
        }
    }
    
    @ViewBuilder
    private var accountListContent: some View {
        if viewModel.accounts.isEmpty {
            emptyAccountsView
            
        } else {
            ForEach(viewModel.accounts, id: \.name) { account in
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
