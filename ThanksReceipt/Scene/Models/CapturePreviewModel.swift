//
//  CapturePreviewModel.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/15.
//

import SwiftUI

final class CapturePreviewModel: ObservableObject {
    private let maxSelectableCount = 7
    @Published var selectedColor: Color = .white
    @Published var message: String?
    @Published var selectedSections: [ReceiptSectionModel] = []
    
    var colorList: [Color] = [
        .white, .black, .blue, .green, .yellow, .orange, .pink, .red, .purple
    ]
    
    var totalCount: String { selectedSections.totalCount }
    
    var selectedCountText: String { "\(selectedSections.count)/\(maxSelectableCount)" }
    
    let rowHeight: CGFloat = 30
    let padding: CGFloat = 10
    let extraAreaHeight: CGFloat = 260
    
    var receiptHeight: CGFloat {
        let rowHeights = rowHeight * CGFloat(selectedSections.itemsCount)
        let footerHeight = padding * CGFloat(selectedSections.count)
        return rowHeights + footerHeight + extraAreaHeight
    }
    
    var snapshotSize: CGFloat { receiptHeight + 70 }
    
    func didSelectSection(_ section: ReceiptSectionModel) {
        guard selectedSections.count <= maxSelectableCount else {
            message = "7개 항목까지 선택할 수 있어요."
            return
        }
        
        if let index = selectedSections.firstIndex(of: section) {
            selectedSections.remove(at: index)
        } else {
            selectedSections.append(section)
        }
    }
    
    func didTapHeader() {
        message = "우측 컬러 휠 버튼을 눌러주세요."
    }
    
    func onAppear() {
        message = "헤더와 푸터 영역의 텍스트를 변경할 수 있어요."
    }
}
