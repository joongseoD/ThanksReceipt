//
//  ReceiptModel.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import SwiftUI
import Combine

protocol ReceiptModelDependency {
    var provider: DataProviding { get }
}

struct ReceiptModelComponents: ReceiptModelDependency {
    var provider: DataProviding = DataProvider()
    // TODO: - Scheduler
}

final class ReceiptModel: ObservableObject {
    @Published private(set) var receiptItems: [ReceiptSectionModel] = []
    @Published private(set) var totalCount: String = "0.00"
    @Published private(set) var monthText: String = ""
    @Published var message: String?
    @Published var inputMode: ReceiptInputModel.InputMode?
    @Published var scrollToId: String?
    @Published var selectedMonth: Date = Date()

    private var provider: DataProviding
    private let items = PassthroughSubject<[ReceiptItem], Never>()
    private let reload = CurrentValueSubject<Void, Never>(())
    private let selectedItemId = PassthroughSubject<String, Never>()
    private let scrollFocusId = PassthroughSubject<String?, Never>()
    private var cancellables = Set<AnyCancellable>()
    private lazy var pagingController = PagingController<ReceiptItem>(items: items.eraseToAnyPublisher(), size: pageSize) // TODO: - scheduler
    
    let pageSize = 100
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        formatter.locale = Locale(identifier: "En")
        return formatter
    }()
    
    
    init(dependency: ReceiptModelDependency = ReceiptModelComponents()) {
        self.provider = dependency.provider
        
        setup()
    }
    
    deinit {
        print("\(String(describing: self)) deinit")
    }
    
    private func setup() {
        reload
            .withLatestFrom($selectedMonth)
            .flatMap { [weak self] month -> AnyPublisher<[ReceiptItem], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                return self.provider.receiptItemList(in: month)
                    .subscribe(on: DispatchQueue.global())
                    .catch { [weak self] error -> AnyPublisher<[ReceiptItem], Never> in
                        DispatchQueue.main.async {
                            self?.message = error.localizedDescription
                        }
                        return Just([]).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] in self?.items.send($0) }
            .store(in: &cancellables)
        
        pagingController.pageItems
            .map { $0.map { ReceiptRowModel(model: $0) } }
            .map { Array($0.reversed()) }
            .map { $0.mapToSectionModel() }
            .receive(on: RunLoop.main)
            .assign(to: \.receiptItems, on: self)
            .store(in: &cancellables)
        
        $receiptItems
            .map { $0.totalCount }
            .assign(to: \.totalCount, on: self)
            .store(in: &cancellables)
        
        let lastItemIdWhenFirstLoaded = $receiptItems
            .filter { !$0.isEmpty }
            .first()
            .map { $0.last?.items.last ?? $0.last?.header }
            .map { $0?.id }
            
        let focusId = $receiptItems
            .withLatestFrom(scrollFocusId)
        
        Publishers.Zip(reload, Publishers.Merge(lastItemIdWhenFirstLoaded, focusId))
            .debounce(for: 0.05, scheduler: RunLoop.main)
            .compactMap { $1 }
            .assign(to: \.scrollToId, on: self)
            .store(in: &cancellables)
        
        selectedItemId
            .withLatestFrom(items) { ($0, $1) }
            .compactMap { id, items in
                return items.first(where: { $0.id == id })
            }
            .sink { [weak self]  in self?.editItem($0) }
            .store(in: &cancellables)
        
        $selectedMonth
            .compactMap { [weak self] date in
                self?.dateFormatter.string(from: date)
            }
            .sink { [weak self] date in
                self?.monthText = date
                self?.message = "Hello, \(date)."
            }
            .store(in: &cancellables)
    }
    
    func editItem(_ item: ReceiptItem) {
        inputMode = .edit(item)
    }
    
    func addItem() {
        inputMode = .create
    }
    
    func didAppearRow(_ offset: Int) {
        guard receiptItems.count >= pageSize, offset == 0 else { return }
        pagingController.fetchNext()
    }
    
    func didTapRow(_ id: String) {
        selectedItemId.send(id)
    }
    
    func didTapBackgroundView() {
        closeInputMode()
    }
    
    func didChangeMonth(_ date: Date) {
        selectedMonth = date
        reload.send(())
    }
}

extension ReceiptModel: ReceiptInputModelListener {
    func didSaveRecipt(_ item: ReceiptItem) {
        reload.send(())
        closeInputMode()
        scrollFocusId.send(item.id)
        message = "감사합니다 :)"
    }
    
    func didUpdateReceipt(_ item: ReceiptItem) {
        reload.send(())
        closeInputMode()
        message = "감사합니다 :)"
    }
    
    func didDeleteReceipt(_ item: ReceiptItem) {
        reload.send(())
        closeInputMode()
    }
    
    private func closeInputMode() {
        inputMode = nil
    }
}
