//
//  ReceiptHeader.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/11.
//

import SwiftUI

struct ReceiptHeader: View {
    @ObservedObject var model: ReceiptModel
    
    var body: some View {
        VStack {
            HStack {
                Button(action: model.saveAsImage) {
                    Image(systemName: "printer")
                }
                
                Spacer()
                
                Button(action: model.addItem) {
                    Image(systemName: "pencil")
                }
            }
            .font(.title2)
            .foregroundColor(Color.text)
            
            VStack {
                Text("* Thanks Receipt *")
                Text("******************")
            }
            .customFont(.DungGeunMo, size: 30)
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
    }
}

struct ReceiptHeader_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptHeader(model: ReceiptModel())
    }
}
