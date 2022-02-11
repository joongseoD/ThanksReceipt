//
//  ReceiptView.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import SwiftUI

struct ReceiptView: View {
    @StateObject var model = ReceiptModel()
    
    // TODO: - Loading
    
    var body: some View {
        VStack {
            ReceiptHeader(model: model)
            
            List {
                ForEach(Array(model.receiptItems.enumerated()), id: \.offset) { offset, item in
                    ReceiptItemRow(item: item)
                        .onAppear { model.didAppearRow(offset) }
                }
            }
            .listStyle(.plain)
            
            ReceiptFooter(model: model)
        }
//        .alert(item: $model.errorMessage) { message in
//            Alert(title: Text(message), message: nil, dismissButton: .default(Text("확인")))
//        }
    }
}

struct ReceiptView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptView()
    }
}
