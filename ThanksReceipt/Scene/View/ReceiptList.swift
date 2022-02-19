//
//  ReceiptList.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/15.
//

import SwiftUI

struct ReceiptList: View {
    var items: [ReceiptSectionModel] = []
    var didTapRow: ((_ item: ReceiptRowModel) -> Void)?
    var didAppearRow: ((_ index: Int) -> Void)?
    var didTapSection: ((_ section: ReceiptSectionModel) -> Void)?
    var scrollToId: String?
    var selectedSections: [ReceiptSectionModel]?
    var rowHeight: CGFloat = 30
    var snapshot: Bool = false
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                if snapshot {
                    VStack(spacing: 0) {
                        contents
                    }
                } else {
                    LazyVStack(spacing: 0) {
                        contents
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            .onChange(of: scrollToId, perform: { newValue in
                guard let focusID = newValue else { return }
                scrollProxy.scrollTo(focusID, anchor: .bottom)
            })
        }
    }
    
    private var contents: some View {
        ForEach(Array(items.enumerated()), id: \.offset) { offset, section in
            Section(
                header:
                    Button(action: { didTapRow?(section.header) }) {
                        ReceiptItemRow(sectionModel: section)
                    }
                    .rowStyle(section.header, height: rowHeight)
                    .background(
                        selectionColor(section)
                            .padding(.horizontal, 15)
                    )
                    .onAppear { didAppearRow?(offset) },
                
                footer: LineStroke()
                    .foregroundColor(.gray)
                    .opacity(0.3)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
            ) {
                ForEach(Array(section.items.enumerated()), id: \.offset) { offset, item in
                    Button(action: { didTapRow?(item) }) {
                        ReceiptItemRow(text: item.text)
                    }
                    .rowStyle(item, height: rowHeight)
                    .onAppear { didAppearRow?(offset) }
                    .background(
                        selectionColor(section)
                            .padding(.horizontal, 15)
                    )
                }
            }
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        didTapSection?(section)
                    }
            )
        }
    }
    
    private func selectionColor(_ section: ReceiptSectionModel) -> Color {
        if let sections = selectedSections, sections.contains(section) {
            return Color.gray.opacity(0.2)
        } else {
            return Color.clear
        }
    }
}

fileprivate extension View {
    func rowStyle(_ item: ReceiptRowModel, height: CGFloat) -> some View {
        self.foregroundColor(.black)
            .frame(height: height)
            .padding(.horizontal, 20)
            .id(item.id)
    }
}

struct ReceiptList_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptList()
    }
}
