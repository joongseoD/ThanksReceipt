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
            VStack(spacing: 5) {
                HStack(spacing: 10) {
                    label()
                }
                .customFont(.DungGeunMo, size: 27)
                
                Button(action: { didTapMonth?() }) {
                    HStack {
                        Text(date)
                            .kerning(1.5)
                        if didTapMonth != nil {
                            Image(symbol: .selectDown)
                                .resizable()
                                .frame(width: 10, height: 5)
                        }
                    }
                }
                .customFont(.DungGeunMo, size: 20)
                .foregroundColor(.black)
                .disabled(didTapMonth == nil)
            }
            .padding(.vertical, 15)
            
            LineStroke()
            
            HStack {
                Text("DATE").kerning(1.5)
                Spacer()
                Text("ITEM").kerning(1.5)
                Spacer()
                Text("COUNT").kerning(1.5)
            }
            .customFont(.DungGeunMo, size: 17)
            
            LineStroke()
        }
    }
}

struct ReceiptHeader_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptHeader(date: "") { }
    }
}
