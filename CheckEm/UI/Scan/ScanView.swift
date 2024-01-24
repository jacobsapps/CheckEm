//
//  ScanView.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import CodeScanner
import SwiftUI

struct ScanView: View {
    
    var body: some View {
        CodeScannerView(codeTypes: [.qr]) {
            print($0)
        }
            .edgesIgnoringSafeArea(.all)
            .presentationDragIndicator(.visible)
            .presentationDetents([.fraction(0.75)])
    }
}

#Preview {
    ScanView()
}
