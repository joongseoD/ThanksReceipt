//
//  ToastView.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/17.
//

import SwiftUI

struct ToastViewModifier: ViewModifier {
    @StateObject var model: ToastModel
    @Binding var message: String?
    var animation: Bool
    var duration: Double
    var anchor: Anchor = .center
    var fontSize: CGFloat = 15.5
    
    init(message: Binding<String?>, animation: Bool, duration: Double, anchor: Anchor, fontSize: CGFloat) {
        _model = StateObject(wrappedValue: ToastModel(duration: duration))
        self._message = message
        self.animation = animation
        self.duration = duration
        self.anchor = anchor
        self.fontSize = fontSize
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let maskingMessage = model.maskingMessage {
                VStack {
                    if anchor == .bottom {
                        Spacer()
                    }
                    text(maskingMessage)
                        .customFont(.DungGeunMo, size: fontSize)
                        .multilineTextAlignment(.center)
                        .padding(.all, 20)
                        .foregroundColor(.white)
                        .background(Color.black)
                        .cornerRadius(10)
                        .scaleEffect(x: 1, y: model.scale, anchor: .center)
                        .animation(.easeInOut(duration: 0.1), value: model.scale)
                        .shadow(color: .black.opacity(0.4), radius: 4, x: 1, y: 2)
                    if anchor == .top {
                        Spacer()
                    }
                }
            }
        }
        .onChange(of: message) { newValue in
            model.didReceiveMessage(newValue)
        }
        .onChange(of: model.message) { newValue in
            guard newValue == nil else { return }
            message = newValue
        }
    }
    
    private func text(_ message: String) -> AnyView {
        animation ? AnyView(AnimateText(message)) : AnyView(Text(message))
    }
}

final class ToastModel: ObservableObject {
    @Published var maskingMessage: String?
    @Published var scale: CGFloat = 0
    @Published var message: String?
    
    var hidingWorkItem: DispatchWorkItem?
    let duration: Double
    
    init(duration: Double) {
        self.duration = duration
    }
    
    deinit {
        print("\(String(describing: self)) deinit")
    }
    
    private func reserveHiding() {
        hidingWorkItem?.cancel()
        hidingWorkItem = nil
        hidingWorkItem = DispatchWorkItem { [weak self] in
            self?.scale = 0
            if let _message = self?.message {
                self?.maskingMessage = String(_message.map { _ in "-" })
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self?.maskingMessage = nil
                self?.message = nil
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: hidingWorkItem!)
    }
    
    func didReceiveMessage(_ message: String?) {
        scale = message != nil ? 1 : 0
        
        if let message = message {
            self.message = message
            maskingMessage = message
            reserveHiding()
        }
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
    func toast(message: Binding<String?>, animation: Bool = true, duration: Double = 1.3, anchor: ToastViewModifier.Anchor = .center, fontSize: CGFloat = 15.5) -> some View {
        self.modifier(ToastViewModifier(message: message, animation: animation, duration: duration, anchor: anchor, fontSize: fontSize))
    }
}
