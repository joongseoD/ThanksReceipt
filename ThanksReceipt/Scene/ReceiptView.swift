//
//  ReceiptView.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import SwiftUI

struct ReceiptView: View {
    @StateObject var model = ReceiptModel()
    @State private var showInputView = false
    
    // TODO: - Loading, Alert, Toast
    
    var body: some View {
        ZStack {
            VStack {
                ReceiptHeader(model: model, showInputView: $showInputView)
                
                List {
                    ForEach(Array(model.receiptItems.enumerated()), id: \.offset) { offset, item in
                        ReceiptItemRow(item: item)
                            .onAppear { model.didAppearRow(offset) }
                    }
                }
                .listStyle(.plain)
                
                ReceiptFooter(model: model)
            }
            .padding(.vertical, 15)
            .background(Color.background)
            
            if showInputView {
                ZStack {
                    LinearGradient(colors: [.white.opacity(0.8), .gray.opacity(0.8)],
                                   startPoint: .top,
                                   endPoint: .bottom)
                        .background(Blur(style: .systemUltraThinMaterial).opacity(0.8))
                        .ignoresSafeArea()
                        .onTapGesture { showInputView = false }
                    
                    ReceiptInputView(dependency: ReceiptInputModelComponents(),
                                     listener: model,
                                     showInputView: $showInputView)
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
