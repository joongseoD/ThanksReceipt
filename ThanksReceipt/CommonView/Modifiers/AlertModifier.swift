//
//  AlertModifier.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/19.
//

import SwiftUI

struct AlertModifier: ViewModifier {
    @Binding var model: AlertModel?
    @State private var animationValue: CGFloat = 0.5
    @State private var internalModel: AlertModel?
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let model = model {
                AlertView(model: model,
                          didTapConfirm: { internalModel = nil },
                          didTapCancel: { internalModel = nil })
                    .scaleEffect(y: animationValue)
                    .animation(.spring(response: 0.2, dampingFraction: 0.6, blendDuration: 1.0), value: animationValue)
                    .backgroundBlur(onTapBackground: nil)
            }
        }
        .onChange(of: model) { newValue in
            internalModel = newValue
            animationValue = newValue != nil ? 1 : 0
        }
        .onChange(of: internalModel) { newValue in
            guard newValue == nil else { return }
            animationValue = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                model = nil
            }
        }
    }
}

struct AlertModel: Equatable {
    let message: String
    let confirmButton: AlertModel.Button
    var cancelButton: AlertModel.Button?
    
    struct Button: Equatable {
        private let id = UUID()
        let title: String
        var action: (() -> Void)?
        
        static func == (lhs: AlertModel.Button, rhs: AlertModel.Button) -> Bool {
            return lhs.id == rhs.id && lhs.title == rhs.title
        }
    }
    
    init(message: String, confirmButton: AlertModel.Button, cancelButton: AlertModel.Button? = nil) {
        self.message = message
        self.confirmButton = confirmButton
        self.cancelButton = cancelButton
    }
}

struct AlertView: View {
    var model: AlertModel
    var didTapConfirm: (() -> Void)?
    var didTapCancel: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            Text(model.message)
                .customFont(.DungGeunMo, size: 20)
                .multilineTextAlignment(.center)
                .padding()
            
            Divider()
            
            HStack {
                if let cancelButton = model.cancelButton {
                    Button(action: {
                        cancelButton.action?()
                        didTapCancel?()
                    }) {
                        Text(cancelButton.title)
                    }
                    .buttonStyle(SelectionButtonStyle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Divider()
                }
                Button(action: {
                    model.confirmButton.action?()
                    didTapConfirm?()
                }) {
                    Text(model.confirmButton.title)
                }
                .buttonStyle(SelectionButtonStyle())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .customFont(.DungGeunMo, size: 15)
            .foregroundColor(.text)
            .frame(height: 40)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color.receipt)
        .clipShape(ZigZag())
        .shadow(color: .black.opacity(0.4), radius: 10, y: 5)
        .padding(25)
    }
}

struct AlertModifier_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AlertView(model: .init(message: "", confirmButton: .init(title: "ok", action: nil)))
                      
            AlertView(model: .init(message: "", confirmButton: .init(title: "ok", action: nil), cancelButton: .init(title: "cancel", action: nil)))
        }
        
    }
}

extension View {
    func alert(model: Binding<AlertModel?>) -> some View {
        self.modifier(AlertModifier(model: model))
    }
}
