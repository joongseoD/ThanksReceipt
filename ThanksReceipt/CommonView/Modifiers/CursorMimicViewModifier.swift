//
//  CursorMimicView.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/16.
//

import SwiftUI

struct CursorMimicViewModifier: ViewModifier {
    @State private var alpha: CGFloat = 0
    var show: Bool = false
    
    func body(content: Content) -> some View {
        GeometryReader { proxy in
            ZStack {
                content
    
                if show {
                    RoundedRectangle(cornerRadius: 2)
                        .frame(width: 2, height: proxy.size.height, alignment: .center)
                        .position(x: proxy.size.width, y: (proxy.size.height / 2) + 3)
                        .foregroundColor(Color.blue)
                        .opacity(alpha)
                        .onChange(of: alpha) { newValue in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.easeInOut) {
                                    if newValue == 0 {
                                        alpha = 1
                                    } else if newValue == 1 {
                                        alpha = 0
                                    }
                                }
                            }
                        }
                        .onAppear { alpha = 1 }
                }
            }
        }
    }
}

extension View {
    func cursor(show: Bool) -> some View {
        self.modifier(CursorMimicViewModifier(show: show))
    }
}
