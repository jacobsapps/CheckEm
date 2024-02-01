//
//  View+ColorEffect.swift
//  LearnMetal
//
//  Created by Jacob Bartlett on 06/11/2023.
//

import SwiftUI

extension View {
    
    func eraseBackground(backgroundColor: Color = Color(uiColor: UIColor.secondarySystemGroupedBackground)) -> some View {
        modifier(EraseBackgroundShader(backgroundColor: backgroundColor))
    }
}

struct EraseBackgroundShader: ViewModifier {
    
    let backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .colorEffect(ShaderLibrary.eraseBackground(
                .color(backgroundColor)
            ))
    }
}
