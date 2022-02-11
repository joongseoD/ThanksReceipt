//
//  ReceiptItemRow.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/11.
//

import SwiftUI

struct ReceiptItemRow: View {
    var item: ReceiptItemModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 2.5) {
            Text(item.date)
                .customFont(.DungGeunMo, size: 13)
            
            Spacer()
            
            Text(item.text)
                .lineLimit(2)
                .customFont(.DungGeunMo, size: 15)
            
            Spacer(minLength: 7)
            Spacer()
            
            Text(item.count)
                .customFont(.DungGeunMo, size: 15)
        }
        .padding(.horizontal, 15)
        .padding(.top, item.topPadding)
    }
}

struct ReceiptItemRow_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptItemRow(item: ReceiptItemModel(date: "", text: "", count: ""))
    }
}
