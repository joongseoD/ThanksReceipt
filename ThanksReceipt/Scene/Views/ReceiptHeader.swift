//
//  ReceiptHeader.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/11.
//

import SwiftUI

struct ReceiptHeader: View {
    @ObservedObject var model: ReceiptModel
    @Binding var showInputView: Bool
    
    var body: some View {
        VStack {
            HStack {
                Button(action: model.saveAsImage) {
                    Text("저장")
                        .customFont(.DungGeunMo, size: 15)
                }
                
                Spacer()
                
                Button(action: { showInputView = true }) {
                    Text("추가")
                        .customFont(.DungGeunMo, size: 15)
                }
            }
            
            VStack {
                Text("* Thanks Receipt *")
                    .font(.custom("DungGeunMo", size: 30))
                Text("******************")
                    .customFont(.DungGeunMo, size: 30)
            }
            .padding(.vertical, 20)
            
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
        .padding(.horizontal, 7.5)
        .padding(.horizontal, 15)
    }
}

struct ReceiptHeader_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptHeader(model: ReceiptModel(), showInputView: .constant(false))
    }
}
