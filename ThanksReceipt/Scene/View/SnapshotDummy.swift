//
//  SnapshotDummy.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/18.
//

import SwiftUI

struct SnapshotDummy: View {
    var backgroundColor: Color
    var date: String
    var headerText: String
    var receipts: [ReceiptSectionModel]
    var totalCount: String
    var footerText: String
    var width: CGFloat
    
    var body: some View {
        ZStack {
            backgroundColor
            
            VStack {
                ReceiptHeader(date: date) {
                    Text(headerText)
                        .lineLimit(1)
                }
                .padding(.horizontal, 20)
                
                ReceiptList(items: receipts, snapshot: true)
                
                ReceiptFooter(totalCount: totalCount) {
                    Text(footerText)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 15)
            .background(Color.background)
            .clipShape(ZigZag())
            .shadow(color: .black.opacity(0.4), radius: 10, y: 5)
            .padding(.vertical, 35)
            .frame(width: width)
        }
        .ignoresSafeArea()
        .colorScheme(.light)
    }
}
