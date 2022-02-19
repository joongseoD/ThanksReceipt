//
//  CapturePreviewModel.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/15.
//

import SwiftUI

final class ReceiptSnapshotPreviewModel: ObservableObject {
    private let maxSelectableCount = 7
    @Published var selectedColor: Color = .white {
        didSet { Haptic.trigger() }
    }
    @Published var message: String? {
        didSet {
            guard message != nil else { return }
            Haptic.trigger()
        }
    }
    @Published var headerText: String = Constants.headerText {
        didSet { Haptic.trigger(.soft) }
    }
    @Published var footerText: String = Constants.footerText {
        didSet { Haptic.trigger(.soft) }
    }
    
    @Published var selectedSections: [ReceiptSectionModel] = [] {
        didSet {
            selectedCountText = "\(selectedSections.count)/\(maxSelectableCount)"
        }
    }
    
    @Published var selectedCountText: String?
    @Published var snapshotImage: UIImage?
    
    private var selectedSortedSections: [ReceiptSectionModel] { selectedSections.sorted(by: <) }
    
    let colorList: [Color] = Constants.colorPalette
    
    var totalCount: String { selectedSections.totalCount }
    
    var receiptsEmpty: Bool { selectedSections.isEmpty }
    
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
        Haptic.trigger()
    }
    
    func onAppear() {
        message = "영수증으로 출력하고자 하는 항목들을 선택하세요."
    }
    
    func saveImage(_ dateString: String) {
        guard receiptsEmpty == false else {
            message = "영수증으로 출력하고자 하는 항목들을 선택하세요."
            return
        }
        let screenWidth = Constants.screenWidth
        let padding: CGFloat = 25
        let dummy = SnapshotDummy(
            backgroundColor: selectedColor,
            date: dateString,
            headerText: headerText,
            receipts: selectedSortedSections,
            totalCount: totalCount,
            footerText: footerText,
            width: screenWidth - (padding * 2)
        )
        
        let snapshotWidth = screenWidth - padding
        snapshotImage = dummy.takeScreenshot(size: .init(width: snapshotWidth,
                                                         height: snapshotWidth))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.snapshotImage = nil
            self?.message = "감사영수증이 출력됐어요."
        }
    }
}
