//
//  ToastView.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/17.
//

import SwiftUI

struct ToastViewModifier: ViewModifier {
    @State private var show: Bool = false
    @State private var hideWorkItem: DispatchWorkItem?
    @State private var maskingMessage: String?
    @Binding var message: String?
    var duration: Double
    var anchor: Anchor = .center
    var fontSize: CGFloat = 20
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let maskingMessage = maskingMessage {
                VStack {
                    if anchor == .bottom {
                        Spacer()
                    }
                    AnimateText(maskingMessage)
                        .customFont(.DungGeunMo, size: fontSize)
                        .padding(.all, 20)
                        .foregroundColor(.white)
                        .background(Color.black)
                        .cornerRadius(10)
                        .scaleEffect(x: 1, y: show ? 1 : 0, anchor: .center)
                        .animation(.easeInOut(duration: 0.1), value: show)
                        .shadow(color: .black.opacity(0.4), radius: 4, x: 1, y: 2)
                    if anchor == .top {
                        Spacer()
                    }
                }
            }
        }
        .onChange(of: message) { newValue in
            show = newValue != nil
            
            guard let newValue = newValue else { return }
            maskingMessage = newValue
            reserveHiding()
        }
    }
    
    private func reserveHiding() {
        hideWorkItem?.cancel()
        hideWorkItem = DispatchWorkItem {
            show = false
            if let _message = message {
                maskingMessage = String(_message.map { _ in "-" })
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                maskingMessage = nil
                message = nil
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: hideWorkItem!)
    }
}

extension ToastViewModifier {
    enum Anchor {
        case top
        case center
        case bottom
    }
}

extension View {
    func toast(message: Binding<String?>, duration: Double = 2, anchor: ToastViewModifier.Anchor = .center, fontSize: CGFloat = 20) -> some View {
        self.modifier(ToastViewModifier(message: message, duration: duration, anchor: anchor, fontSize: fontSize))
    }
}
