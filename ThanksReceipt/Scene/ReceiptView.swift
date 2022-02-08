//
//  ReceiptView.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import SwiftUI

struct ReceiptView: View {
    
    private var mockData: [ReceiptItem] = [
//        .init(id: .init(), text: "0", date: Date()),
//        .init(id: .init(), text: "0", date: Date()),
//        .init(id: .init(), text: "0", date: Date()),
//        .init(id: .init(), text: "0", date: Date()),
//        .init(id: .init(), text: "0", date: Date()),
//        .init(id: .init(), text: "0", date: Date()),
//        .init(id: .init(), text: "0", date: Date()),
//        .init(id: .init(), text: "0", date: Date()),
//        .init(id: .init(), text: "0", date: Date()),
//        .init(id: .init(), text: "0", date: Date()),
//        .init(id: .init(), text: "0", date: Date()),
//        .init(id: .init(), text: "0", date: Date()),
//        .init(id: .init(), text: "0", date: Date()),
//        .init(id: .init(), text: "0", date: Date()),
//        .init(id: .init(), text: "0", date: Date()),
        .init(id: .init(), text: "0", date: Date()),
        .init(id: .init(), text: "0", date: Date())
    ]
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {}) {
                    Text("저장")
                }
                
                Spacer()
                
                Button(action: {}) {
                    Text("추가")
                }
            }
            .padding(.horizontal, 15)
            
            VStack {
                Text("* Tanks Receipt *")
                Text("*****************")
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 15)
            
            VStack {
                Text("--------------------------------------------")
                    .lineLimit(0)
                    
                HStack {
                    Text("DATE")
                    Spacer()
                    Text("ITEM")
                    Spacer()
                    Text("COUNT")
                }
                
                Text("--------------------------------------------")
                    .lineLimit(0)
            }
            .padding(.horizontal, 7.5)
            .padding(.horizontal, 15)
            
            List {
                ForEach(mockData, id: \.id) { item in
                    HStack {
                        Text("date")
                        Spacer()
                        Text("itemitemitem")
                        Spacer()
                        Text("1.00")
                    }
                    .padding(.horizontal, 15)
                }
            }
            .listStyle(.plain)
            
            VStack {
                Text("--------------------------------------------")
                    .lineLimit(0)
                
                HStack {
                    Spacer()
                    
                    Text("TOTAL")
                        .padding(.trailing, 15)
                    
                    Text("0.00")
                }
            }
            .padding(.horizontal, 15)
        }
    }
}

struct ReceiptView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptView()
    }
}
