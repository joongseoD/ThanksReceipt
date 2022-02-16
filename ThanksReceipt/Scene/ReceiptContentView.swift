//
//  ReceiptContentView.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/15.
//

import SwiftUI

struct ReceiptContentView: View {
    @EnvironmentObject var model: ReceiptModel
    @Binding var showMonthPicker: Bool
    
    var body: some View {
        VStack {
            ReceiptHeader(date: model.monthText,
                          label: { Text(Constants.headerText).kerning(1.5) },
                          didTapMonth: { showMonthPicker = true })
                .padding(.horizontal, 20)
            
            ReceiptList(items: model.receiptItems,
                        didTapRow: { model.didTapRow($0.id) },
                        didAppearRow: { model.didAppearRow($0) },
                        scrollToId: model.scrollToId)
            
            ReceiptFooter(totalCount: model.totalCount) {
                Text(Constants.footerText)
                    .kerning(1.5)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 15)
        .background(Color.background)
        .clipShape(ZigZag())
    }
}

struct ReceiptContentView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptContentView(showMonthPicker: .constant(false))
    }
}