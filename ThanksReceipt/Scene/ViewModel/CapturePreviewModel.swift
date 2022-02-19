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
    @Published private(set) var selectedSections: [ReceiptSectionModel] = []
    private var selectedSectionModels: [ReceiptSectionModel] = [] {
        didSet {
            selectedSections = selectedSectionModels.sorted(by: <)
        }
    }
    
    let colorList: [Color] = Constants.colorPalette
    
    var totalCount: String { selectedSections.totalCount }
    
    var selectedCountText: String { "\(selectedSections.count)/\(maxSelectableCount)" }
    
    func didSelectSection(_ section: ReceiptSectionModel) {
        if let index = selectedSectionModels.firstIndex(of: section) {
            selectedSectionModels.remove(at: index)
        } else {
            guard selectedSectionModels.count < maxSelectableCount else {
                message = "7개 항목까지 선택할 수 있어요."
                return
            }
            selectedSectionModels.append(section)
        }
    }
    
    func onAppear() {
        message = "영수증으로 출력하고자 하는 항목들을 선택하세요."
    }
}
