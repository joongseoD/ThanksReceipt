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
    var mock: Bool { get set }
    var provider: DataProviding { get }
    var mainScheduler: AnySchedulerOf<DispatchQueue> { get }
    var deletionDate: PassthroughSubject<Date, Never> { get }
    var reload: CurrentValueSubject<Void, Never> { get }
}

final class ReceiptModel: ObservableObject {
    @Published private(set) var receiptItems: [ReceiptSectionModel] = []
    @Published private(set) var totalCount: String = "0.00"
    @Published private(set) var monthText: String = ""
    @Published var message: String?
    @Published var alert: AlertModel?
    @Published var scrollToId: String?
    @Published var selectedMonth: Date = Date()
    @Published var viewState: ViewState?
    
    private let scrollFocusId = PassthroughSubject<String?, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private var dependency: ReceiptModelDependency
    private let service: ReceiptModelServicing
    
    private var mainScheduler: AnySchedulerOf<DispatchQueue> { dependency.mainScheduler }
    private var reload: CurrentValueSubject<Void, Never> { dependency.reload }
    private var deletionDate: PassthroughSubject<Date, Never> { dependency.deletionDate }
    
    init(dependency: ReceiptModelDependency, service: ReceiptModelServicing) {
        self.dependency = dependency
        self.service = service
        
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
            .sink(receiveValue: { [weak self] in self?.receiptItems = $0 })
            .store(in: &cancellables)
        
        sectionModels
            .map { $0.totalCount }
            .sink(receiveValue: { [ weak self] in self?.totalCount = $0 })
            .store(in: &cancellables)
        
        let lastItemIdWhenFirstLoaded = sectionModels
            .filter { !$0.isEmpty }
            .first()
            .map { $0.last?.items.last ?? $0.last?.header }
            .map { $0?.id }
            
        let focusId = sectionModels
            .withLatestFrom(scrollFocusId)
        
        Publishers.Zip(reload, Publishers.Merge(lastItemIdWhenFirstLoaded, focusId))
            .debounce(for: 0.05, scheduler: mainScheduler)
            .compactMap { $1 }
            .sink(receiveValue: { [weak self] in self?.scrollToId = $0 })
            .store(in: &cancellables)
        
        service.errorPublisher
            .map { $0.dataErrorDescription }
            .receive(on: mainScheduler)
            .sink(receiveValue: { [weak self] in self?.message = $0 })
            .store(in: &cancellables)
        
        service.foundReceiptItem
            .receive(on: mainScheduler)
            .sink { [weak self]  in self?.editItem($0) }
            .store(in: &cancellables)
        
        $selectedMonth
            .compactMap { DateFormatter(format: .longMonth).string(from: $0) }
            .sink { [weak self] date in
                self?.monthText = date
                self?.message = "Hello, \(date)."
            }
            .store(in: &cancellables)
        
        deletionDate
            .filter { [weak self] _ in self?.viewState == nil }
            .sink { [weak self] in self?.deleteReceipt(in: $0) }
            .store(in: &cancellables)
    }
    
    func deleteReceipt(in date: Date) {
        let dateformatter = DateFormatter(format: .shortMonthDayWeek)
        let dateString = dateformatter.string(from: date)
        alert = AlertModel(
            message: "\(dateString) 항목을 지울까요?",
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
            try service.delete(date)
            service.reload()
            
            Logger.shared.send(
                name: "didDeleteReceipt",
                parameters: ["date" : date.description]
            )
        } catch {
            message = error.dataErrorDescription
        }
    }
    
    func didTapRow(_ id: String) {
        service.findReceiptItem(by: id)
    }
    
    func editItem(_ item: ReceiptItem) {
        viewState = .input(
            ReceiptInputModelComponents(
                dependency: dependency,
                mode: .edit(item),
                date: selectedMonth
            )
        )
    }
    
    func addItem() {
        viewState = .input(
            ReceiptInputModelComponents(
                dependency: dependency,
                mode: .create,
                date: selectedMonth
            )
        )
    }
    
    func didTapSave() {
        viewState = .snapshotPreview(
            ReceiptSnapshotPreviewModelComponent(
                scrollToId: scrollToId,
                monthText: monthText,
                totalCount: totalCount,
                receiptItems: receiptItems
            )
        )
    }
    
    func didTapMonth() {
        viewState = .monthPicker(
            MonthPickerModelComponents(
                currentDate: selectedMonth
            )
        )
    }

    func didLongPressHeader() {
        #if DEBUG
        dependency.mock.toggle()
        message = dependency.mock == true ? "Mockup" : "Live"
        #endif
    }
}

extension ReceiptModel: ReceiptInputModelListener {
    func didSaveRecipt(_ item: ReceiptItem) {
        service.reload()
        closeOverlayView()
        scrollFocusId.send(item.id)
        message = "감사가 기록됐어요."
        
        Logger.shared.send(
            name: "didSaveReceipt",
            parameters: item.asDictionary()
        )
    }
    
    func didUpdateReceipt(_ item: ReceiptItem) {
        service.reload()
        closeOverlayView()
        message = "감사가 기록됐어요."
        
        Logger.shared.send(
            name: "didUpdateReceipt",
            parameters: item.asDictionary()
        )
    }
    
    func didDeleteReceipt(_ item: ReceiptItem) {
        service.reload()
        closeOverlayView()
        
        Logger.shared.send(
            name: "didDeleteReceipt",
            parameters: item.asDictionary()
        )
    }
    
    func didTapBackgroundView() {
        closeOverlayView()
    }
    
    private func closeOverlayView() {
        viewState = nil
    }
}

extension ReceiptModel: MonthPickerModelListener {
    func didSelectDate(_ date: Date) {
        selectedMonth = date
        service.didChangedDate(date)
        service.reload()
        closeOverlayView()
    }
}

extension ReceiptModel {
    enum ViewState: Equatable {
        case monthPicker(_: MonthPickerModelDependency)
        case input(_: ReceiptInputModelDependency)
        case snapshotPreview(_: ReceiptSnapshotPreviewModelDependency)
        
        static func == (lhs: ReceiptModel.ViewState, rhs: ReceiptModel.ViewState) -> Bool {
            switch (lhs, rhs) {
            case let (.monthPicker(lItem), .monthPicker(rItem)):
                return lItem.currentDate == rItem.currentDate
            case let (.input(lItem), .input(rItem)):
                return lItem.mode == rItem.mode
            case let (.snapshotPreview(lItem), .snapshotPreview(rItem)):
                return lItem.receiptItems == rItem.receiptItems
            default:
                return false
            }
        }
    }
}

struct ReceiptInputModelComponents: ReceiptInputModelDependency {
    let dependency: ReceiptModelDependency
    var provider: DataProviding { dependency.provider }
    var mainScheduler: AnySchedulerOf<DispatchQueue> { dependency.mainScheduler }
    
    var mode: ReceiptInputModel.InputMode
    var date: Date = Date()
}

struct ReceiptSnapshotPreviewModelComponent: ReceiptSnapshotPreviewModelDependency {
    var colorList: [Palette] = Constants.paletteColors
    var scrollToId: String?
    var monthText: String
    var totalCount: String
    var receiptItems: [ReceiptSectionModel]
    var imageManager: ImageManagerProtocol = ImageManager()
}

struct MonthPickerModelComponents: MonthPickerModelDependency {
    var currentDate: Date
}
