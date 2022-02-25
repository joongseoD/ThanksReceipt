//
//  Stripe.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/25.
//

import SwiftUI

struct Stripes: Shape, Hashable {
    var stripes: Int = 30
    var insertion: Bool = true
    var ratio: CGFloat
    
    var animatableData: CGFloat {
        get { ratio }
        set { ratio = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let stripeWidth = rect.width / CGFloat(stripes)
        let rects = (0..<stripes).map { (index) -> CGRect in
            let xOffset = CGFloat(index) * stripeWidth
            let adjustment = insertion ? 0 : (stripeWidth * (1 - ratio))
            return CGRect(x: xOffset + adjustment, y: 0, width: stripeWidth * ratio, height: rect.height)
        }
        
        path.addRects(rects)
        return path
    }
}

struct ShapeClipModifier<S>: ViewModifier where S: Shape {
    let shape: S
    func body(content: Content) -> some View {
        content
            .clipShape(shape)
    }
}
