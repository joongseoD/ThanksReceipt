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
    var backgroundScheduler: AnySchedulerOf<DispatchQueue> { get }
    var deletionDate: PassthroughSubject<Date, Never> { get }
    var reload: CurrentValueSubject<Void, Never> { get }
    var selectedDate: CurrentValueSubject<Date, Never> { get }
}

protocol ReceiptModelServicing: AnyObject {
    var sectionModels: AnyPublisher<[ReceiptSectionModel], Never> { get }
    var errorPublisher: AnyPublisher<Error, Never> { get }
    var foundReceiptItem: AnyPublisher<ReceiptItem, Never> { get }
    
    func findReceiptItem(by id: String)
    func reload()
    func didChangedDate(_ date: Date)
    func delete(_ date: Date) throws
}

final class ReceiptModelService: ReceiptModelServicing {
    private let items = PassthroughSubject<[ReceiptItem], Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private let _errorPublisher = PassthroughSubject<Error, Never>()
    var errorPublisher: AnyPublisher<Error, Never> {
        _errorPublisher.eraseToAnyPublisher()
    }
    
    private let findReceiptItemId = PassthroughSubject<String, Never>()
    lazy var foundReceiptItem: AnyPublisher<ReceiptItem, Never> = {
        findReceiptItemId
            .withLatestFrom(items) { ($0, $1) }
            .compactMap { id, items in
                return items.first(where: { $0.id == id })
            }
            .eraseToAnyPublisher()
    }()
    
    private var selectedDate: CurrentValueSubject<Date, Never> { dependency.selectedDate }
    
    private var reloadSubject: CurrentValueSubject<Void, Never> { dependency.reload }
    
    private var backgroundScheduler: AnySchedulerOf<DispatchQueue> { dependency.backgroundScheduler }
    
    private var provider: DataProviding { dependency.provider }
    
    private let dependency: ReceiptModelServiceDependency
    
    init(dependency: ReceiptModelServiceDependency) {
        self.dependency = dependency
        
        setup()
    }
    
    deinit {
        print("\(String(describing: self)) deinit")
    }
    
    private func setup() {
        reloadSubject
            .withLatestFrom(selectedDate)
            .flatMap { [weak self] month -> AnyPublisher<[ReceiptItem], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                return self.provider.receiptItemList(in: month)
                    .subscribe(on: self.backgroundScheduler)
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
        items
            .map { $0.map { ReceiptRowModel(model: $0) } }
            .map { Array($0.reversed()) }
            .map { [weak self] in
                $0.mapToSectionModel(
                    dependency: ReceiptSectionModelComponents(
                        tappedDateSubject: self?.dependency.deletionDate
                    )
                )
            }
            .share(replay: 1)
            .eraseToAnyPublisher()
    }()
    
    func findReceiptItem(by id: String) {
        findReceiptItemId.send(id)
    }
    
    func reload() {
        reloadSubject.send(())
    }
    
    func didChangedDate(_ date: Date) {
        selectedDate.send(date)
    }
    
    func delete(_ date: Date) throws {
        try provider.delete(date: date)
    }
}
