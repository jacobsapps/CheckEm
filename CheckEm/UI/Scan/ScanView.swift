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
              let url = URL(string: scan.string),
              let account = SecretURLParser.shared.account2FA(from: url),
              let _ = try? KeychainManager.shared.storeAccount(named: account.name, url: url) else { return }
        onScan(account)
    }
}

#Preview {
    ScanView { _ in }
}
