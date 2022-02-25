//
//  SectionModelService.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/25.
//

import Foundation
import Combine
import CombineSchedulers

protocol ReceiptModelServiceDependency {
    var provider: DataProviding { get }
    var pageSize: Int { get }
    var scheduler: AnySchedulerOf<DispatchQueue> { get }
    var selectedDate: AnyPublisher<Date, Never> { get }
    var deletingDate: PassthroughSubject<Date, Never> { get }
    var reload: AnyPublisher<Void, Never> { get}
}

struct ReceiptModelServiceComponents: ReceiptModelServiceDependency {
    var provider: DataProviding = DataProvider()
    var pageSize: Int = 100
    var scheduler: AnySchedulerOf<DispatchQueue> = .main
    var selectedDate: AnyPublisher<Date, Never>
    var deletingDate: PassthroughSubject<Date, Never>
    var reload: AnyPublisher<Void, Never>
}

protocol ReceiptModelServicing: AnyObject {
    var sectionModels: AnyPublisher<[ReceiptSectionModel], Never> { get }
    var errorPublisher: AnyPublisher<Error, Never> { get }
    var foundReceiptItem: AnyPublisher<ReceiptItem, Never> { get }
    
    func fetchNextPage()
    func findReceiptItem(by id: String)
}

final class ReceiptModelService: ReceiptModelServicing {
    private let pageSize: Int
    private let items = PassthroughSubject<[ReceiptItem], Never>()
    private lazy var pagingController = PagingController<ReceiptItem>(items: items.eraseToAnyPublisher(), size: pageSize)
    private var cancellables = Set<AnyCancellable>()
    
    private let _errorPublisher = PassthroughSubject<Error, Never>()
    var errorPublisher: AnyPublisher<Error, Never> {
        _errorPublisher.eraseToAnyPublisher()
    }
    
    private var selectedDate: AnyPublisher<Date, Never> { dependency.selectedDate }
    
    private var reload: AnyPublisher<Void, Never> { dependency.reload }
    
    private var scheduler: AnySchedulerOf<DispatchQueue> { dependency.scheduler }
    
    private let dependency: ReceiptModelServiceDependency
    
    private let provider: DataProviding
    
    init(dependency: ReceiptModelServiceDependency) {
        self.dependency = dependency
        self.provider = dependency.provider
        self.pageSize = dependency.pageSize
        
        setup()
    }
    
    deinit {
        print("\(String(describing: self)) deinit")
    }
    
    private func setup() {
        reload
            .withLatestFrom(selectedDate)
            .flatMap { [weak self] month -> AnyPublisher<[ReceiptItem], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                return self.provider.receiptItemList(in: month)
                    .subscribe(on: self.scheduler)
                    .catch { [weak self] error -> AnyPublisher<[ReceiptItem], Never> in
                        self?._errorPublisher.send(error)
                        return Just([]).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] in self?.items.send($0) }
            .store(in: &cancellables)
    }
    
    lazy var sectionModels: AnyPublisher<[ReceiptSectionModel], Never> = {
        pagingController.pageItems
            .map { $0.map { ReceiptRowModel(model: $0) } }
            .map { Array($0.reversed()) }
            .map { [weak self] in
                $0.mapToSectionModel(
                    dependency: ReceiptSectionModelComponents(
                        tappedDateSubject: self?.dependency.deletingDate
                    )
                )
            }
            .share(replay: 1)
            .eraseToAnyPublisher()
    }()
    
    private let findReceiptItemId = PassthroughSubject<String, Never>()
    lazy var foundReceiptItem: AnyPublisher<ReceiptItem, Never> = {
        findReceiptItemId
            .withLatestFrom(items) { ($0, $1) }
            .compactMap { id, items in
                return items.first(where: { $0.id == id })
            }
            .eraseToAnyPublisher()
    }()
    
    func findReceiptItem(by id: String) {
        findReceiptItemId.send(id)
    }
    
    func fetchNextPage() {
        pagingController.fetchNext()
    }
}
