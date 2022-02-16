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
    
    var colorList: [Color] = [
        .white, .black, .blue, .green, .yellow, .orange, .pink, .red, .purple
    ]
    
    var selectedItems: [ReceiptItemModel] = []
    
    var totalCount: String { sectionModels.totalCount }
        
    var sectionModels: [ReceiptSectionModel] { selectedItems.mapToSectionModel() }
    
    func didSelectItem(_ item: ReceiptItemModel) {
        guard selectedItems.count <= maxSelectableCount else {
            message = "7개 항목까지 선택할 수 있어요."
            return
        }
        selectedItems.append(item)
    }
    
    func didTapHeader() {
        message = "우측 컬러 휠 버튼을 눌러주세요."
    }
    
    func onAppear() {
        message = "헤더와 푸터 영역의 텍스트를 변경할 수 있어요."
    }
}
