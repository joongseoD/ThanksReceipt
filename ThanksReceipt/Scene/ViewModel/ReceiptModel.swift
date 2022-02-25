//
//  ReceiptModel.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import SwiftUI
import Combine
import CombineSchedulers

protocol ReceiptModelDependency {
    var provider: DataProviding { get }
    var pageSize: Int { get }
    var mainScheduler: AnySchedulerOf<DispatchQueue> { get }
}

struct ReceiptModelComponents: ReceiptModelDependency {
    var provider: DataProviding = DataProvider()
    var pageSize: Int = 100
    var mainScheduler: AnySchedulerOf<DispatchQueue> = .main
}

final class ReceiptModel: ObservableObject {
    @Published private(set) var receiptItems: [ReceiptSectionModel] = []
    @Published private(set) var totalCount: String = "0.00"
    @Published private(set) var monthText: String = ""
    @Published var message: String?
    @Published var alert: AlertModel?
    @Published var scrollToId: String?
    @Published var selectedMonth: Date = Date()
    @Published var selectedSections: [ReceiptSectionModel] = []
    @Published var viewState: ViewState?
    
    private let pageSize: Int
    private let reload = CurrentValueSubject<Void, Never>(())
    private let scrollFocusId = PassthroughSubject<String?, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var selectMode: Bool = false {
        didSet {
            guard !selectMode else { return }
            selectedSections = []
        }
    }
    
    let provider: DataProviding
    private let mainScheduler: AnySchedulerOf<DispatchQueue>
    private let deletingDate = PassthroughSubject<Date, Never>()
    
    private lazy var service: ReceiptModelServicing = {
        ReceiptModelService(
            dependency: ReceiptModelServiceComponents(
                provider: provider,
                pageSize: pageSize,
                scheduler: mainScheduler, // TODO: - background
                selectedDate: $selectedMonth.eraseToAnyPublisher(),
                deletingDate: deletingDate,
                reload: reload.eraseToAnyPublisher()
            )
        )
    }()
    
    private let dateFormatter = DateFormatter(format: .longMonth)
    
    init(dependency: ReceiptModelDependency = ReceiptModelComponents()) {
        self.provider = dependency.provider
        self.mainScheduler = dependency.mainScheduler
        self.pageSize = dependency.pageSize
        
        setup()
        
        Logger.shared.sendScreenLog(viewName: "ReceiptView")
    }
    
    deinit {
        print("\(String(describing: self)) deinit")
    }
    
    private func setup() {
        let sectionModels = service.sectionModels
            .receive(on: mainScheduler)
        
        sectionModels
            .assign(to: \.receiptItems, on: self)
            .store(in: &cancellables)
        
        sectionModels
            .map { $0.totalCount }
            .assign(to: \.totalCount, on: self)
            .store(in: &cancellables)
        
        let lastItemIdWhenFirstLoaded = sectionModels
            .filter { !$0.isEmpty }
            .first()
            .map { $0.last?.items.last ?? $0.last?.header }
            .map { $0?.id }
            
        let focusId = sectionModels
            .withLatestFrom(scrollFocusId)
        
        Publishers.Zip(reload.print("#3"), Publishers.Merge(lastItemIdWhenFirstLoaded, focusId))
            .debounce(for: 0.05, scheduler: mainScheduler)
            .compactMap { $1 }
            .assign(to: \.scrollToId, on: self)
            .store(in: &cancellables)
        
        service.errorPublisher
            .map { $0.localizedDescription }
            .receive(on: mainScheduler)
            .assign(to: \.message, on: self)
            .store(in: &cancellables)
        
        service.foundReceiptItem
            .receive(on: mainScheduler)
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
        
        deletingDate
            .sink { [weak self] in self?.deleteReceipt(in: $0) }
            .store(in: &cancellables)
    }
    
    func deleteReceipt(in date: Date) {
        let dateformatter = DateFormatter(format: .shortMonthDayWeek)
        let dateString = dateformatter.string(from: date)
        alert = AlertModel(
            message: "\(dateString) 감사를 지울까요?",
            confirmButton: .init(
                title: "네",
                action: { [weak self] in
                    self?.delete(date)
                }
            ),
            cancelButton: .init(
                title: "아니요"
            )
        )
    }
    
    private func delete(_ date: Date) {
        do {
            try provider.delete(date: date)
            reload.send(())
            
            Logger.shared.send(
                name: "didDeleteReceipt",
                parameters: ["date" : date.description]
            )
        } catch {
            message = error.localizedDescription
        }
    }
    
    func editItem(_ item: ReceiptItem) {
        viewState = .input(.edit(item))
    }
    
    func addItem() {
        viewState = .input(.create)
    }
    
    func didAppearRow(_ offset: Int) {
        guard receiptItems.count >= pageSize, offset == 0 else { return }
        service.fetchNextPage()
    }
    
    func didTapRow(_ id: String) {
        guard !selectMode else { return }
        service.findReceiptItem(by: id)
    }
    
    func didTapBackgroundView() {
        closeOverlayView()
    }
    
    func didSelectSection(_ section: ReceiptSectionModel) {
        guard selectMode else { return }
        if let index = selectedSections.firstIndex(of: section) {
            selectedSections.remove(at: index)
        } else {
            selectedSections.append(section)
        }
        Haptic.trigger()
        
        selectMode = !selectedSections.isEmpty
    }
    
    func didLongPressSection(_ section: ReceiptSectionModel) {
        selectMode.toggle()
        didSelectSection(section)
    }
    
    func didTapSave() {
        viewState = .snapshotPreview
    }
    
    func didTapMonth() {
        viewState = .monthPicker
    }
}

extension ReceiptModel: ReceiptInputModelListener {
    func didSaveRecipt(_ item: ReceiptItem) {
        reload.send(())
        closeOverlayView()
        scrollFocusId.send(item.id)
        message = "감사합니다 :)"
        
        Logger.shared.send(
            name: "didSaveReceipt",
            parameters: item.asDictionary()
        )
    }
    
    func didUpdateReceipt(_ item: ReceiptItem) {
        reload.send(())
        closeOverlayView()
        message = "감사합니다 :)"
        
        Logger.shared.send(
            name: "didUpdateReceipt",
            parameters: item.asDictionary()
        )
    }
    
    func didDeleteReceipt(_ item: ReceiptItem) {
        reload.send(())
        closeOverlayView()
        
        Logger.shared.send(
            name: "didDeleteReceipt",
            parameters: item.asDictionary()
        )
    }
    
    private func closeOverlayView() {
        viewState = nil
    }
}

extension ReceiptModel: MonthPickerModelListener {
    func didSelectDate(_ date: Date) {
        selectedMonth = date
        reload.send(())
        closeOverlayView()
    }
}

extension ReceiptModel {
    enum ViewState: Equatable {
        case monthPicker
        case input(_: ReceiptInputModel.InputMode)
        case snapshotPreview
        case bottomSheet
    }
}
