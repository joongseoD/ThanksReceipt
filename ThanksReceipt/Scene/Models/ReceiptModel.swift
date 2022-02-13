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
    @Published var inputMode: ReceiptInputModel.InputMode?
    private var provider: DataProviding
    private let items = PassthroughSubject<[ReceiptItem], Never>()
    private let reload = CurrentValueSubject<Void, Never>(())
    private let selectedItemId = PassthroughSubject<String, Never>()
    private let _captureListHeight = PassthroughSubject<CGFloat, Never>()
    private var cancellables = Set<AnyCancellable>()
    private lazy var pagingController = PagingController<ReceiptItem>(items: items.eraseToAnyPublisher(), size: pageSize)
    
    var captureListHeight: AnyPublisher<CGFloat, Never> { _captureListHeight.eraseToAnyPublisher() }
    let pageSize = 10
    
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
                    .receive(on: RunLoop.main)
                    .catch { [weak self] error -> AnyPublisher<[ReceiptItem], Never> in
                        self?.errorMessage = error.localizedDescription
                        print("# err", error.localizedDescription)
                        return Just([]).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] in self?.items.send($0) }
            .store(in: &cancellables)
        
        pagingController.pageItems
            .filter { !$0.isEmpty }
            .map { $0.map { ReceiptItemModel(model: $0) } }
            .receive(on: RunLoop.main)
            .sink { [weak self] items in
                self?.receiptItems = items
            }
            .store(in: &cancellables)
        
        selectedItemId
            .withLatestFrom(items) { ($0, $1) }
            .compactMap { id, items in
                return items.first(where: { $0.id == id })
            }
            .sink { [weak self]  in self?.editItem($0) }
            .store(in: &cancellables)
    }
    
    func editItem(_ item: ReceiptItem) {
        inputMode = .edit(item)
    }
    
    func addItem() {
        inputMode = .create
    }
    
    func saveAsImage() {
        _captureListHeight.send(CGFloat(receiptItems.count * 30))
    }
    
    func didAppearRow(_ offset: Int) {
        guard offset <= receiptItems.count else { return }
        guard receiptItems.count - 1 == offset else { return }
        pagingController.fetchNext()
    }
    
    func didTapRow(_ id: String) {
        selectedItemId.send(id)
    }
    
    func didTapBackgroundView() {
        closeInputMode()
    }
}

extension ReceiptModel: ReceiptInputModelListener {
    func didSaveRecipt(_ item: ReceiptItem) {
        reload.send(())
        closeInputMode()
    }
    
    func didUpdateReceipt(_ item: ReceiptItem) {
        reload.send(())
        closeInputMode()
    }
    
    private func closeInputMode() {
        inputMode = nil
    }
}
