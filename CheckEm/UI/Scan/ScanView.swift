//
//  ScanView.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import CodeScanner
import SwiftUI

struct ScanView: View {
    
    let onScan: (Account) -> Void
    
    var body: some View {
        CodeScannerView(codeTypes: [.qr],
                        scanMode: .continuous,
                        showViewfinder: true) {
            handleScan($0)
        }
            .edgesIgnoringSafeArea(.all)
            .presentationDragIndicator(.visible)
            .presentationDetents([.fraction(0.75)])
    }
    
    private func handleScan(_ result: Result<ScanResult, ScanError>) {
        guard case .success(let scan) = result,
            let url = URL(string: scan.string),
            let account = account2FA(from: url) else { return }
        print(account)
        onScan(account)
    }
    
    private func account2FA(from url: URL) -> Account? {
        print(url)
        guard url.scheme == "otpauth" else { return nil }
        
        guard let name = url.path
            .removingPercentEncoding?
            .replacingOccurrences(of: "/", with: "")
            .replacingOccurrences(of: ":", with: " - ") else { return nil }

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              let secretItem = queryItems.first(where: { $0.name == "secret" }),
              let secret = secretItem.value else { return nil }
        print(secret)
        return Account(name: name, base32String: secret)
    }

}

#Preview {
    ScanView { _ in }
}
