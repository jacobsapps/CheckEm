//
//  Color.metal
//  LearnMetal
//
//  Created by Jacob Bartlett on 06/11/2023.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[ stitchable ]]
half4 eraseBackground(
    float2 position,
    half4 color,
    half4 backgroundColor
) {
    
    if (color.r >= 0.95 && color.g >= 0.95 && color.b >= 0.95) {
        return backgroundColor;
    }

    return color;
}
