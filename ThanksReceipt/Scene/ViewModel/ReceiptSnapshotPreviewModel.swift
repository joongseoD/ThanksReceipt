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
    var imageManager: ImageManagerProtocol { get }
}

struct ReceiptSnapshotPreviewModelComponent: ReceiptSnapshotPreviewModelDependency {
    var colorList: [Palette] = Constants.paletteColors
    var scrollToId: String?
    var monthText: String
    var totalCount: String
    var receiptItems: [ReceiptSectionModel]
    var imageManager: ImageManagerProtocol = ImageManager()
}

final class ReceiptSnapshotPreviewModel: ObservableObject {
    private let maxSelectableCount = 7
    @Published var snapshotImage: UIImage?
    @Published var scrollToId: String?
    @Published var selectedSections: [ReceiptSectionModel] = []
    @Published var willDisappear: Bool = false
    @Published var state: ViewState = .edit {
        didSet { Haptic.trigger() }
    }
    
    @Published var selectedColor: Palette = .single(.white) {
        didSet { Haptic.trigger() }
    }
    
    @Published var headerText: String = Constants.headerText {
        didSet { Haptic.trigger(.soft) }
    }
    
    @Published var footerText: String = Constants.footerText {
        didSet { Haptic.trigger(.soft) }
    }
    
    @Published var message: String? {
        didSet {
            guard message != nil else { return }
            Haptic.trigger()
        }
    }
    
    private let dependency: ReceiptSnapshotPreviewModelDependency
    private let imageManager: ImageManagerProtocol
    
    init(dependency: ReceiptSnapshotPreviewModelDependency) {
        self.dependency = dependency
        self.imageManager = dependency.imageManager
    }
    
    var receiptsEmpty: Bool { selectedSections.isEmpty }
    var colorList: [Palette] { dependency.colorList }
    var receiptItems: [ReceiptSectionModel] { dependency.receiptItems }
    var totalCount: String { dependency.totalCount }
    var dateString: String { dependency.monthText }
    var selectedCountText: String { "\(selectedSections.count)/\(maxSelectableCount)" }
    
    deinit {
        print("\(String(describing: self)) deinit")
    }
}

extension ReceiptSnapshotPreviewModel {
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
    
    func nextStep() {
        switch state {
        case .edit:
            guard receiptsEmpty == false else {
                printDefaultMessage()
                return
            }
            
            if let image = renderImage(AnyView(Color.clear)) {
                state = .selectBackground(image)
            } else {
                printErrorMessage()
            }
        case .selectBackground:
            let background = AnyView(ColorBuilderView(palette: selectedColor))
            guard let image = renderImage(background) else {
                printErrorMessage()
                return
            }
            
            saveImage(image)
        }
    }
    
    private func renderImage(_ backgroundView: AnyView) -> UIImage? {
        let screenWidth = Constants.screenWidth
        let padding: CGFloat = 25
        let dummy = SnapshotDummy(
            background: backgroundView,
            date: dateString,
            headerText: headerText,
            receipts: selectedSortedSections,
            totalCount: selectedSections.totalCount,
            footerText: footerText,
            width: screenWidth - (padding * 2)
        )
        
        let snapshotWidth = screenWidth - padding
        return dummy.takeScreenshot(size: .init(width: snapshotWidth, height: snapshotWidth))
    }
    
    private var selectedSortedSections: [ReceiptSectionModel] { selectedSections.sorted(by: <) }
    
    private func saveImage(_ image: UIImage) {
        imageManager.save(image: image) { [weak self] result in
            switch result {
            case .success(_):
                self?.snapshotImage = image
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self?.snapshotImage = nil
                    self?.message = "감사영수증이 출력됐어요."
                }
            case .failure(_):
                self?.message = "사진 저장 권한을 확인해주세요."
            }
        }
    }
    
    private func printErrorMessage() {
        message = "잠시 후 다시 시도해주세요"
    }
    
    private func printDefaultMessage() {
        message = "감사 항목을 선택해주세요!"
    }
    
    func didTapBackStep() {
        switch state {
        case .edit:
            willDisappear = true
        case .selectBackground:
            state = .edit
        }
    }
}

extension ReceiptSnapshotPreviewModel {
    enum ViewState: Equatable {
        case edit
        case selectBackground(_ image: UIImage)
        
        var buttonTitle: String {
            switch self {
            case .edit: return "배경 선택하기"
            case .selectBackground: return "영수증 출력하기"
            }
        }
    }
}

/*
protocol ListSelectable: AnyObject {
    associatedtype Item: Equatable
    var maxSelectableCount: Int { get }
    var selectableList: [Item] { get set }
}

extension ListSelectable {
    func didSelect(_ item: Item) {
        if let index = selectableList.firstIndex(of: item) {
            selectableList.remove(at: index)
        } else {
            guard selectableList.count < maxSelectableCount else {
//                message = "7개 항목까지 선택할 수 있어요."
                return
            }
            selectableList.append(item)
        }
        Haptic.trigger()
    }
}
*/
