//
//  ReceiptHeader.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/11.
//

import SwiftUI

struct ReceiptHeader<Label: View>: View {
    var date: String
    var label: (() -> Label)
    var didTapMonth: (() -> Void)?
    
    init(date: String, @ViewBuilder label: @escaping () -> Label, didTapMonth: (() -> Void)? = nil) {
        self.date = date
        self.label = label
        self.didTapMonth = didTapMonth
    }
    
    var body: some View {
        VStack {
            VStack {
                Button(action: { didTapMonth?() }) {
                    HStack {
                        Text(date)
                        if didTapMonth != nil {
                            Image(systemName: "chevron.compact.down")
                                .resizable()
                                .frame(width: 10, height: 5)
                        }
                    }
                }
                .customFont(.DungGeunMo, size: 22)
                .foregroundColor(.black)
                .disabled(didTapMonth == nil)
                .padding(.bottom, 5)
                
                label()
                Text("******************")
            }
            .customFont(.DungGeunMo, size: 30)
            .padding(.bottom, 20)
            
            LineStroke()
            
            HStack {
                Text("DATE")
                Spacer()
                Text("ITEM")
                Spacer()
                Text("COUNT")
            }
            .customFont(.DungGeunMo, size: 20)
            
            LineStroke()
        }
    }
}

struct ReceiptHeader_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptHeader(date: "") { }
    }
}
