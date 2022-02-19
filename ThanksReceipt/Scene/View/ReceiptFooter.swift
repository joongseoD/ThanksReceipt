//
//  ReceiptFooter.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/11.
//

import SwiftUI

struct ReceiptFooter<Label: View>: View {
    var totalCount: String
    var label: (() -> Label)
    
    init(totalCount: String, @ViewBuilder label: @escaping () -> Label) {
        self.totalCount = totalCount
        self.label = label
    }
    
    var body: some View {
        VStack {
            LineStroke()
            
            HStack {
                Spacer()
                
                Text("TOTAL")
                    .kerning(1.5)
                    .padding(.trailing, 15)
                
                Text(totalCount)
            }
            .customFont(.DungGeunMo, size: 20)
            
            HStack {
                Text("**")
                Spacer()
                label()
                Spacer()
                Text("**")
            }
            .customFont(.DungGeunMo, size: 19)
            .padding(.top, 5)
        }
        .padding(.vertical, 10)
    }
}

struct ReceiptFooter_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptFooter(totalCount: "") { }
    }
}
