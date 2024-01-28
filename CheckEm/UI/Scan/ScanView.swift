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
                        scanMode: .once) {
            handleScan($0)
        }
            .edgesIgnoringSafeArea(.all)
            .presentationDragIndicator(.visible)
            .presentationDetents([.fraction(0.55)])
    }
    
    private func handleScan(_ result: Result<ScanResult, ScanError>) {
        guard case .success(let scan) = result,
              let url = URL(string: scan.string) else { return }
        guard let account = account2FA(from: url) else { return }
        onScan(account)
    }
    
    private func account2FA(from url: URL) -> Account? {
        guard url.scheme == "otpauth" else { return nil }
        
        guard let name = url.path
            .removingPercentEncoding?
            .replacingOccurrences(of: "/", with: "")
            .replacingOccurrences(of: ":", with: " — ") else { return nil }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              let secret = queryItems.first(where: { $0.name == "secret" })?.value,
              let issuer = queryItems.first(where: { $0.name == "issuer" })?.value else { return nil }
        
        return try? Account(name: String(name), base32String: secret, issuer: issuer)
    }
}

#Preview {
    ScanView { _ in }
}
