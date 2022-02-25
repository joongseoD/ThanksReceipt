//
//  ReceiptContentView.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/15.
//

import SwiftUI

struct ReceiptContentView: View {
    @EnvironmentObject var model: ReceiptModel
    
    var body: some View {
        VStack {
            ReceiptHeader(
                date: model.monthText,
                label: {
                    Text(Constants.headerText)
                        .kerning(1.5)
                        .multilineTextAlignment(.center)
                },
                didTapMonth: model.didTapMonth
            )
                .padding(.horizontal, 20)
            
            ReceiptList(
                items: model.receiptItems,
                didTapRow: { model.didTapRow($0.id) },
                didAppearRow: { model.didAppearRow($0) },
                scrollToId: model.scrollToId
            )
            
            ReceiptFooter(totalCount: model.totalCount) {
                AnimateText([Constants.headerText, Constants.footerText],
                            kerning: 1.5,
                            duration: 2)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 15)
        .background(Color.receipt)
        .clipShape(ZigZag())
        .shadow(color: .black.opacity(0.4), radius: 10, y: 5)
    }
}

struct ReceiptContentView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptContentView()
    }
}
