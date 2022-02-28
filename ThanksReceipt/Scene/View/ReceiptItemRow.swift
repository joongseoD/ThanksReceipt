//
//  ReceiptItemRow.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/11.
//

import SwiftUI

struct ReceiptItemRow: View {
    @Environment(\.contentsScale) private var contentsScale: CGFloat
    private var sectionModel: ReceiptSectionModel?
    var date: String = ""
    var text: String = ""
    var count: String = ""
    
    init(sectionModel: ReceiptSectionModel) {
        self.sectionModel = sectionModel
        self.date = sectionModel.dateString
        self.text = sectionModel.text
        self.count = sectionModel.countString
    }
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Button(action: { sectionModel?.didTapDate() }) {
                Text(date)
                    .customFont(.DungGeunMo, size: 13 * contentsScale)
            }
            .frame(maxWidth: 55 * contentsScale, alignment: .leading)
            
            Text(text)
                .lineSpacing(2)
                .multilineTextAlignment(.leading)
                .customFont(.DungGeunMo, size: 13 * contentsScale)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            
            Spacer()
            
            Text(count)
                .kerning(1.5)
                .frame(minWidth: 38, alignment: .trailing)
                .customFont(.DungGeunMo, size: 13 * contentsScale)
        }
        .padding(.vertical, 5)
        .offset(y: -2)
    }
}

struct ReceiptItemRow_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptItemRow(text: "")
    }
}
