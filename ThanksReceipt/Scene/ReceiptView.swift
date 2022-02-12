//
//  ReceiptView.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import SwiftUI

struct ReceiptView: View {
    @StateObject var model = ReceiptModel()
    // TODO: - Loading, Alert, Toast
    
    var body: some View {
        ZStack {
            VStack {
                ReceiptHeader(model: model)
                
                List {
                    ForEach(Array(model.receiptItems.enumerated()), id: \.offset) { offset, item in
                        ReceiptItemRow(item: item)
                            .listRowBackground(Color.background)
                            .onAppear { model.didAppearRow(offset) }
                            .onTapGesture { model.didTapRow(offset) }
                    }
                }
                .listStyle(.sidebar)
                
                ReceiptFooter(model: model)
            }
            .padding(.vertical, 15)
            .background(Color.background)
            
            if model.inputMode != nil {
                ZStack {
                    LinearGradient(colors: [.white.opacity(0.8), .gray.opacity(0.8)],
                                   startPoint: .top,
                                   endPoint: .bottom)
                        .background(Blur(style: .systemUltraThinMaterial).opacity(0.8))
                        .ignoresSafeArea()
                        .onTapGesture(perform: model.didTapBackgroundView)
                    
                    ReceiptInputView(dependency: ReceiptInputModelComponents(mode: model.inputMode!),
                                     listener: model)
                }
                .transition(.opacity.animation(.easeInOut))
            }
        }
        .clipShape(ZigZag())
    }
}

struct ReceiptView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptView()
    }
}
