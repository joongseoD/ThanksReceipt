//
//  ReceiptFooter.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/11.
//

import SwiftUI

struct ReceiptFooter: View {
    @ObservedObject var model: ReceiptModel
    
    var body: some View {
        VStack {
            LineStroke()
            
            HStack {
                Spacer()
                
                Text("TOTAL")
                    .padding(.trailing, 15)
                
                Text(model.totalCount)
            }
            .customFont(.DungGeunMo, size: 20)
            
            HStack {
                Text("**")
                Spacer()
                Text("THANKS FOR\nGIVING ME A DAY!")
                    .multilineTextAlignment(.center)
                Spacer()
                Text("**")
            }
            .customFont(.DungGeunMo, size: 20)
            .padding(.top, 5)
        }
        .padding(.vertical, 10)
    }
}

struct ReceiptFooter_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptFooter(model: ReceiptModel())
    }
}
