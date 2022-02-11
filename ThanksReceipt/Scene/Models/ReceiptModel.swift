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
    @Published private(set) var receiptItems: [ReceiptItemModel] = []
    @Published private(set) var totalCount: String = "0.00"
    @Published private(set) var errorMessage: String?
    let pageSize = 10
    
    private var provider: DataProviding
    private let items = PassthroughSubject<[ReceiptItem], Never>()
    private let reload = CurrentValueSubject<Void, Never>(())
    private var cancellables = Set<AnyCancellable>()
    private lazy var pagingController = PagingController<ReceiptItem>(items: items.eraseToAnyPublisher(), size: pageSize)
    
    init(dependency: ReceiptModelDependency = ReceiptModelComponents()) {
        self.provider = dependency.provider
        
        setup()
    }
    
    deinit {
        print("\(String(describing: self)) deinit")
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
                self?.receiptItems.append(contentsOf: items)
            }
            .store(in: &cancellables)
    }

    func saveAsImage() {
        
    }
    
    func addItem() {
        
    }
    
    func didAppearRow(_ offset: Int) {
        guard offset <= receiptItems.count else { return }
        guard receiptItems.count - 1 == offset else { return }
        pagingController.next()
    }
}

extension ReceiptModel: ReceiptInputModelListener {
    func didSaveRecipt(_ item: ReceiptItem) {
        // TODO: - 날짜 찾아서 날짜 중 가장 마지막에 추가 
        receiptItems.insert(ReceiptItemModel(model: item), at: 0)
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
