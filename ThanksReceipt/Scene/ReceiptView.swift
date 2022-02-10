//
//  ReceiptView.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import SwiftUI

struct ReceiptView: View {
    @StateObject var model = ReceiptModel()
    
    var body: some View {
        VStack {
            HStack {
                Button(action: model.saveAsImage) {
                    Text("저장")
                        .customFont(.DungGeunMo, size: 15)
                }
                
                Spacer()
                
                Button(action: model.addItem) {
                    Text("추가")
                        .customFont(.DungGeunMo, size: 15)
                }
            }
            .padding(.horizontal, 15)
            
            VStack {
                Text("* Thanks Receipt *")
                    .font(.custom("DungGeunMo", size: 30))
                Text("*****************")
                    .customFont(.DungGeunMo, size: 30)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 15)
            
            VStack {
                Text("--------------------------------------------")
                    .lineLimit(0)
                    .customFont(.DungGeunMo, size: 20)
                    .overlay(
                        GeometryReader { proxy in
                            HStack {
                                Color.white
                                Spacer(minLength: proxy.frame(in: .global).width - 10)
                                Color.white
                            }
                        }
                    )
                    
                HStack {
                    Text("DATE")
                    Spacer()
                    Text("ITEM")
                    Spacer()
                    Text("COUNT")
                }
                .customFont(.DungGeunMo, size: 20)
                
                Text("--------------------------------------------")
                    .lineLimit(0)
                    .customFont(.DungGeunMo, size: 20)
            }
            .padding(.horizontal, 7.5)
            .padding(.horizontal, 15)
            
            List {
                ForEach(Array(model.receiptItems.enumerated()), id: \.offset) { offset, item in
                    HStack {
                        Text(item.date)
                        Spacer()
                        Text(item.text)
                        Spacer()
                        Spacer()
                        Text(item.count)
                    }
                    .customFont(.DungGeunMo, size: 15)
                    .padding(.horizontal, 15)
                    .padding(.top, item.topPadding)
                    .onAppear { model.didAppearRow(offset) }
                }
            }
            .listStyle(.plain)
            
            VStack {
                Text("--------------------------------------------")
                    .lineLimit(0)
                    .customFont(.DungGeunMo, size: 20)
                
                HStack {
                    Spacer()
                    
                    Text("TOTAL")
                        .padding(.trailing, 15)
                    
                    Text(model.totalCount)
                }
                .customFont(.DungGeunMo, size: 20)
            }
            .padding(.horizontal, 15)
        }
//        .alert(item: $model.errorMessage) { message in
//            Alert(title: Text(message), message: nil, dismissButton: .default(Text("확인")))
//        }
    }
}

struct ReceiptView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptView()
    }
}
