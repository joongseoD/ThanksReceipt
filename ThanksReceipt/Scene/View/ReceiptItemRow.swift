//
//  ReceiptItemRow.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/11.
//

import SwiftUI

struct ReceiptItemRow: View {
    var date: String = ""
    var text: String = ""
    var count: String = ""
    
    init(sectionModel: ReceiptSectionModel) {
        self.date = sectionModel.dateString
        self.text = sectionModel.text
        self.count = sectionModel.countString
    }
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 2.5) {
            Text(date)
                .customFont(.DungGeunMo, size: 13)
                .frame(width: 60, alignment: .leading)
            
            Text(text)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .customFont(.DungGeunMo, size: 15)
                .padding(.leading, 10)
            
            Spacer()
            
            Text(count)
                .kerning(1.5)
                .frame(minWidth: 50, alignment: .trailing)
                .customFont(.DungGeunMo, size: 15)
        }
    }
}

struct ReceiptItemRow_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptItemRow(text: "")
    }
}
