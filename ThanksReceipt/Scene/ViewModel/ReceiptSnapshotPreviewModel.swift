//
//  CapturePreviewModel.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/15.
//

import SwiftUI

protocol ReceiptSnapshotPreviewModelDependency {
    var colorList: [Palette] { get }
    var scrollToId: String? { get }
    var monthText: String { get }
    var totalCount: String { get }
    var receiptItems: [ReceiptSectionModel] { get }
}

struct ReceiptSnapshotPreviewModelComponent: ReceiptSnapshotPreviewModelDependency {
    var colorList: [Palette] = Constants.paletteColors
    var scrollToId: String?
    var monthText: String
    var totalCount: String
    var receiptItems: [ReceiptSectionModel]
}

final class ReceiptSnapshotPreviewModel: ObservableObject {
    private let maxSelectableCount = 7
    @Published var snapshotImage: UIImage?
    @Published var scrollToId: String?
    @Published var selectedColor: Palette = .single(.white) {
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
    
    @Published var selectedSections: [ReceiptSectionModel] = []
    
    private let dependency: ReceiptSnapshotPreviewModelDependency
    
    init(dependency: ReceiptSnapshotPreviewModelDependency) {
        self.dependency = dependency
    }
    
    var receiptsEmpty: Bool { selectedSections.isEmpty }
    var colorList: [Palette] { dependency.colorList }
    var receiptItems: [ReceiptSectionModel] { dependency.receiptItems }
    var totalCount: String { dependency.totalCount }
    var dateString: String { dependency.monthText }
    var selectedCountText: String { "\(selectedSections.count)/\(maxSelectableCount)" }
    
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
        printDefaultMessage()
        scrollToId = dependency.scrollToId
    }
    
    func saveImage() {
        guard receiptsEmpty == false else {
            printDefaultMessage()
            return
        }
        let screenWidth = Constants.screenWidth
        let padding: CGFloat = 25
        let background = AnyView(ColorBuilderView(palette: selectedColor))
        let dummy = SnapshotDummy(
            background: background,
            date: dateString,
            headerText: headerText,
            receipts: selectedSortedSections,
            totalCount: selectedSections.totalCount,
            footerText: footerText,
            width: screenWidth - (padding * 2)
        )
        
        let snapshotWidth = screenWidth - padding
        guard let snapshot = dummy.takeScreenshot(size: .init(width: snapshotWidth, height: snapshotWidth)) else {
            message = "잠시후 다시 시도해 주세요."
            return
        }
        
        snapshotImage = snapshot
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            self?.snapshotImage = nil
            self?.message = "감사영수증이 출력됐어요."
            self?.selectedSections = []
        }
    }
    
    private var selectedSortedSections: [ReceiptSectionModel] { selectedSections.sorted(by: <) }
    
    private func printDefaultMessage() {
        message = "영수증으로 출력하고자 하는 항목들을 선택하세요."
    }
    
    deinit {
        print("\(String(describing: self)) deinit")
    }
}
