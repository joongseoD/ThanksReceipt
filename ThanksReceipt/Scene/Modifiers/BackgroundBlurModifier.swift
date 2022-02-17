//
//  BackgroundBlurModifier.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/15.
//

import SwiftUI

struct BackgroundBlurModifier: ViewModifier {
    var onTapBackground: (() -> Void)?
    
    func body(content: Content) -> some View {
        ZStack {
            LinearGradient(colors: [.white.opacity(0.8), .gray.opacity(0.8)],
                           startPoint: .top,
                           endPoint: .bottom)
                .background(Blur(style: .systemUltraThinMaterial).opacity(0.8))
                .ignoresSafeArea()
                .onTapGesture(perform: { onTapBackground?() })
            
            content
        }
    }
}

extension View {
    func backgroundBlur(onTapBackground: (() -> Void)? = nil) -> some View {
        self.modifier(BackgroundBlurModifier(onTapBackground: onTapBackground))
    }
}
