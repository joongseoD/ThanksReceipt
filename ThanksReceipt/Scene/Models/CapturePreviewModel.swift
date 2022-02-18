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
    
    // TODO: - 정렬해야됨
    func didSelectSection(_ section: ReceiptSectionModel) {
        if let index = selectedSections.firstIndex(of: section) {
            selectedSections.remove(at: index)
        } else {
            guard selectedSections.count < maxSelectableCount else {
                message = "7개 항목까지 선택할 수 있어요."
                return
            }
            selectedSections.append(section)
        }
    }
    
    func onAppear() {
        message = "영수증으로 출력하고자 하는 항목들을 선택하세요."
    }
}
