//
//  ReceiptList.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/15.
//

import SwiftUI

struct ReceiptList: View {
    @EnvironmentObject var model: ReceiptModel
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack {
                    ForEach(Array(model.receiptItems.enumerated()), id: \.offset) { offset, section in
                        Section(
                            header:
                                Button(action: { model.didTapRow(section.header.id) }) {
                                    ReceiptItemRow(sectionModel: section)
                                }
                                .foregroundColor(.black)
                                .frame(height: 20)
                                .padding(.horizontal, 20)
                                .id(section.header.id)
                                .onAppear { model.didAppearRow(offset) },
                            footer: LineStroke()
                                .foregroundColor(.gray)
                                .opacity(0.3)
                                .padding(.horizontal, 20)
                        ) {
                            ForEach(Array(section.items.enumerated()), id: \.offset) { offset, item in
                                Button(action: { model.didTapRow(item.id) }) {
                                    ReceiptItemRow(text: item.text)
                                }
                                .foregroundColor(.black)
                                .frame(height: 20)
                                .padding(.horizontal, 20)
                                .id(item.id)
                                .onAppear { model.didAppearRow(offset) }
                            }
                        }
                    }
                }
                .transition(.move(edge: .bottom))
            }
            .onChange(of: model.scrollToId, perform: { newValue in
                guard let focusID = newValue else { return }
                scrollProxy.scrollTo(focusID, anchor: .bottom)
            })
        }
    }
}

struct ReceiptList_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptList()
    }
}
