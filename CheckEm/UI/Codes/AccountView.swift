//
//  AccountView.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 28/01/2024.
//

import CachedAsyncImage
import SwiftUI
import TipKit

struct AccountView: View {
    
    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 36
    @State private var showCopied: Bool = false
    let account: Account
    
    var body: some View {
//        Section(String(account.name.split(separator: "—").first ?? "")) {
        Section(account.name) {
            Button(action: {
                copyCode()
            }, label: {
                HStack(alignment: .center, spacing: 16) {
                    icon
                    code
                    countdown
                }
                .contentShape(Rectangle())
            })
        }
    }
    
    private var icon: some View {
        CachedAsyncImage(url: FavIcon(issuer: account.issuer).url, content: {
            $0
                .resizable()
                .aspectRatio(contentMode: .fit)
//                .eraseBackground()
            
        }, placeholder: {
            Text(String(account.issuer.first ?? account.name.first ?? Character("")))
                .font(.largeTitle)
                .monospaced()
        })
        .frame(width: iconSize, height: iconSize, alignment: .center)
    }
    
    private var code: some View {
        ViewThatFits {
            HStack(alignment: .center, spacing: 16) {
                codeText
            }
            VStack(alignment: .leading, spacing: 4) {
                codeText
            }
        }
    }
    
    @ViewBuilder
    private var codeText: some View {
        Text(account.code ?? "------")
            .fontDesign(.monospaced)
            .fontWeight(.bold)
            .font(.largeTitle)
            .foregroundStyle(Color.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        if showCopied {
            Text("Copied")
                .font(.caption)
                .foregroundStyle(Color.primary)
        }
    }
    
    private var countdown: some View {
        CountdownView(countdown: account.countdown)
            .id(account.name)
    }
    
    private func copyCode() {
        if let code = account.code {
            UIPasteboard.general.string = code
            withAnimation {
                showCopied = true
            }
        }
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            await MainActor.run {
                withAnimation {
                    showCopied = false
                }
            }
        }
    }
}

struct CountdownView: View {
    
    @ScaledMetric(relativeTo: .caption) var tickSize: CGFloat = 3
    @ScaledMetric(relativeTo: .body) var tickOffset: CGFloat = 20
    @ScaledMetric(relativeTo: .body) var countdownTextWidth: CGFloat = 28
    
    let countdown: Int?
    
    var body: some View {
        ZStack {
            clockFace
            number
        }
        .animation(.bouncy, value: countdown)
        .padding(.trailing, tickOffset / 2.0)
        .overlay {
            if countdown == nil {
                ProgressView()
            }
        }
    }
    
    @ViewBuilder
    private var number: some View {
        if let countdown {
            Text("\(countdown)")
                .font(.body)
                .fontWeight(.medium)
                .fontDesign(.monospaced)
                .foregroundStyle(Color.primary)
                .transition(.opacity)
                .frame(width: countdownTextWidth, alignment: .center)
        }
    }
    
    @ViewBuilder
    private var clockFace: some View {
        if let countdown {
            ForEach(0..<30) {
                let angle = Angle.degrees(Double($0 * 12))
                Circle()
                    .frame(width: tickSize)
                    .foregroundColor(countdown <= $0 ? .clear : .green)
                    .offset(x: -tickOffset * cos(CGFloat(angle.radians)),
                            y: tickOffset * sin(CGFloat(angle.radians)))
            }
            .transition(.opacity)
            .rotationEffect(.degrees(90))
        }
    }
}
