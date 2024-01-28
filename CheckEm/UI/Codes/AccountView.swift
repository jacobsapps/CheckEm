//
//  AccountView.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 28/01/2024.
//

import CachedAsyncImage
import SwiftUI

struct AccountView: View {
    
    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 36
    let account: Account
    
    var body: some View {
//        Section(String(account.name.split(separator: "—").first ?? "")) {
        Section(account.name) {
            HStack(alignment: .center, spacing: 16) {
                CachedAsyncImage(url: FavIcon(issuer: account.issuer).url, content: {
                    $0
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .eraseBackground()
                    
                }, placeholder: {
                    Text(String(account.issuer.first ?? Character("")))
                        .font(.title)
                })
                .frame(width: iconSize, height: iconSize, alignment: .center)
                
                Text(account.code ?? "------")
                    .fontDesign(.monospaced)
                    .fontWeight(.bold)
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let countdown = account.countdown {
                    CountdownView(countdown: countdown)
                }
            }
        }
    }
}

struct CountdownView: View {
    
    @ScaledMetric(relativeTo: .body) var tickSize: CGFloat = 3
    @ScaledMetric(relativeTo: .body) var tickOffset: CGFloat = 20
    let countdown: Int
    
    var body: some View {
        ZStack {
            clockFace
            number
        }
        .padding(.trailing, tickOffset)
    }
    
    private var number: some View {
        Text("\(countdown)")
            .font(.body)
            .fontWeight(.medium)
            .fontDesign(.monospaced)
    }
    
    private var clockFace: some View {
        ForEach(0..<30) {
            let angle = Angle.degrees(Double($0 * 12))
            Circle()
                .frame(width: tickSize)
                .foregroundColor(countdown <= $0 ? .clear : .green)
                .rotationEffect(angle)
                .offset(x: tickOffset * cos(CGFloat(angle.radians)),
                        y: tickOffset * sin(CGFloat(angle.radians)))
        }
    }
}
