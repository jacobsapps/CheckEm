//
//  CodeView.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import CachedAsyncImage
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
                    AccountView(account: account)
                }
                .onDelete(perform: viewModel.delete)
                .animation(.bouncy, value: viewModel.accounts)
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

struct AccountView: View {
    
    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 36
    let account: Account
    
    var body: some View {
        Section(String(account.name.split(separator: "—").first ?? "")) {
            HStack(alignment: .center, spacing: 16) {
                CachedAsyncImage(url: FavIcon(issuer: account.issuer).url, content: {
                    $0
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize, height: iconSize)
                        .eraseBackground()
                    
                }, placeholder: {
                    Text(String(account.issuer.first ?? Character("")))
                        .font(.title)
                })
                
                Text(account.code ?? "")
                    .fontDesign(.monospaced)
                    .fontWeight(.bold)
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(account.countdown ?? "")
                    .fontWeight(.medium)
                    .font(.caption)
            }
        }
    }
}

struct FavIcon {
    
    let url: URL
    
    init(issuer: String) {
        let domain = "\(issuer).com"
        let url = URL(string: "https://www.google.com/s2/favicons?sz=256&domain=\(domain)")!
        self.url = url
    }
}

#Preview {
    CodeView()
}
