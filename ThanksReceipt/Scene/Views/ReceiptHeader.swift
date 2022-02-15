//
//  ReceiptHeader.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/11.
//

import SwiftUI

struct ReceiptHeader: View {
    @EnvironmentObject var model: ReceiptModel
    @Binding var showMonthPicker: Bool
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text(model.monthText)
                    Image(systemName: "chevron.compact.down")
                        .resizable()
                        .frame(width: 10, height: 5)
                }
                .customFont(.DungGeunMo, size: 22)
                .padding(.bottom, 5)
                .onTapGesture { showMonthPicker = true }
                
                Text("* Thanks Receipt *")
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
        ReceiptHeader(showMonthPicker: .constant(false))
    }
}
