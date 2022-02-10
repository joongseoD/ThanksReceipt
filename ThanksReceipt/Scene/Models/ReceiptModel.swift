//
//  ReceiptModel.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import Foundation
import Combine
import SwiftUI

protocol ReceiptModelDependency {
    var provider: DataProviding { get }
}

struct ReceiptModelComponents: ReceiptModelDependency {
    var provider: DataProviding = DataProvider()
    // TODO: - Scheduler
}

final class ReceiptModel: ObservableObject {
    @Published var receiptItems: [ReceiptItemModel] = []
    @Published var totalCount: String = "0.00"
    @Published var errorMessage: String?
    let pageSize = 10
    
    private var provider: DataProviding
    private let items = PassthroughSubject<[ReceiptItem], Never>()
    private lazy var pagingController = PagingController<ReceiptItem>(items: items.eraseToAnyPublisher(), size: pageSize)
    private var cancellables = Set<AnyCancellable>()
    
    private let reload = CurrentValueSubject<Void, Never>(())
    
    init(dependency: ReceiptModelDependency = ReceiptModelComponents()) {
        self.provider = dependency.provider
        
        setup()
    }
    
    private func setup() {
        reload
            .flatMap { [weak self] _ -> AnyPublisher<[ReceiptItem], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                return self.provider.receiptItemList()
                    .subscribe(on: DispatchQueue.global())
                    .catch { [weak self] error -> AnyPublisher<[ReceiptItem], Never> in
                        self?.errorMessage = error.localizedDescription
                        return Just([]).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] in self?.items.send($0) }
            .store(in: &cancellables)
        
        pagingController.pageItems
            .map { $0.map { ReceiptItemModel(model: $0) } }
            .receive(on: RunLoop.main)
            .sink { [weak self] items in
                self?.receiptItems += items
            }
            .store(in: &cancellables)
    }
}

extension ReceiptModel {
    func saveAsImage() {
        
    }
    
    func addItem() {
        // TODO: - 입력뷰 띄워서
        do {
            let item = ReceiptItem(text: "\(receiptItems.count)", date: Date())
            try provider.create(receiptItem: item)
            receiptItems.insert(ReceiptItemModel(model: item), at: 0)
        } catch {
            errorMessage = "생성 에러\n\(error.localizedDescription)"
        }
    }
    
    func didAppearRow(_ offset: Int) {
        guard offset <= receiptItems.count else { return }
        let margin = receiptItems.count - offset
        guard margin <= 2 else { return }
        pagingController.next()
    }
}

struct ReceiptItemModel {
    var date: String
    var text: String
    var count: String = ""
    var isSubItem: Bool = false
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d (E)"
        dateFormatter.locale = Locale(identifier: "ko")
        return dateFormatter
    }()
    
    var topPadding: CGFloat {
        isSubItem ? 0 : 10
    }
    
    init(date: String, text: String, count: String, isSubItem: Bool = false) {
        self.date = date
        self.text = text
        self.count = count
        self.isSubItem = isSubItem
        setup()
    }
    
    init(model: ReceiptItem, isSubItem: Bool = false) {
        self.text = model.text
        self.count = ""
        self.date = dateFormatter.string(from: model.date)
        self.isSubItem = isSubItem
        
        setup()
    }
    
    private func setup() {
        
    }
}
