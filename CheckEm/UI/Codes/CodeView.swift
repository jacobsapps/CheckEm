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
                OTPView(name: viewModel.accountName,
                        currentCode: viewModel.currentCode,
                        dateString: viewModel.dateString,
                        countdown: viewModel.countdown)
                .onReceive(timer) { _ in
                    viewModel.refresh()
                }
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
                    print($0)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}

// qrcode.viewfinder
// qrcode
// gear

struct OTPView: View {
    
    let name: String
    let currentCode: String
    let dateString: String
    let countdown: String
    
    var body: some View {
        Section(name) {
            HStack {
                Text(currentCode)
                    .fontDesign(.monospaced)
                    .fontWeight(.bold)
                    .font(.largeTitle)
                
                Text(countdown)
                    .fontWeight(.medium)
                    .font(.caption)
            }
            Text(dateString)
                .font(.body)
        }
    }
}

#Preview {
    CodeView()
}
