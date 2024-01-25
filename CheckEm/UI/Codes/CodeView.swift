//
//  CodeView.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import SwiftUI

struct CodeView: View {
    
    @State private var showScanner: Bool = false
    @State private var showSettings: Bool = false
    @State private var viewModel = CodeViewModel()
    private let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.accounts, id: \.self) { account in
                    OTPView(account: account)
                }
                .onDelete(perform: viewModel.delete)
            }
            .onReceive(timer) { _ in
                viewModel.refresh()
            }
            .navigationTitle("Check 'em")
            .toolbar {
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
            .sheet(isPresented: $showScanner) {
                ScanView {
                    showScanner = false
                    viewModel.create(account: $0)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .task {
                await viewModel.task()
            }
        }
    }
    
    private func delete(at offsets: IndexSet) {
        viewModel.delete(at: offsets)
    }
}

struct OTPView: View {
    
    let account: Account
//    let name: String
//    let currentCode: String
//    let countdown: String
    
    var body: some View {
        Section(account.name) {
            HStack {
                Text("000000") // currentCode)
                    .fontDesign(.monospaced)
                    .fontWeight(.bold)
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("20")//countdown)
                    .fontWeight(.medium)
                    .font(.caption)
            }
        }
    }
}

#Preview {
    CodeView()
}
