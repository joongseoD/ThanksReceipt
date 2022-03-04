//
//  ReceiptInputModel.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import SwiftUI
import Combine
import CombineSchedulers

protocol ReceiptInputModelDependency {
    var provider: DataProviding { get }
    var mainScheduler: AnySchedulerOf<DispatchQueue> { get }
    var mode: ReceiptInputModel.InputMode { get }
    var date: Date { get }
}

protocol ReceiptInputModelListener: AnyObject {
    func didSaveRecipt(_ item: ReceiptItem)
    func didUpdateReceipt(_ item: ReceiptItem)
    func didDeleteReceipt(_ item: ReceiptItem)
}

final class ReceiptInputModel: ObservableObject {
    @Published private(set) var textCount: String = ""
    @Published private(set) var dateString: String = ""
    @Published var inputMode: InputMode?
    @Published var message: String?
    @Published var alert: AlertModel?
    @Published var date: Date
    @Published var text: String = ""
    private let provider: DataProviding
    private let mainScheduler: AnySchedulerOf<DispatchQueue>
    private let maxCount: Int = Constants.inputMaxLength
    private var cancellables = Set<AnyCancellable>()
    private let dateFormatter = DateFormatter(format: .longMonthDayWeek)
    
    private weak var listener: ReceiptInputModelListener?
    
    init(dependency: ReceiptInputModelDependency, listener: ReceiptInputModelListener?) {
        self.provider = dependency.provider
        self.mainScheduler = dependency.mainScheduler
        self.inputMode = dependency.mode
        self.date = dependency.date
        self.listener = listener
        
        setup()
    }
    
    private func setup() {
        $inputMode
            .compactMap { mode -> ReceiptItem? in
                switch mode {
                case let .edit(item):
                    return item
                default:
                    return nil
                }
            }
            .sink { [weak self] item in
                self?.text = item.text
                self?.date = item.date
            }
            .store(in: &cancellables)
        
        $text
            .map { $0.count }
            .receive(on: mainScheduler)
            .sink { [weak self] textCount in
                guard let self = self else { return }
                if textCount > self.maxCount {
                    self.text = String(self.text.prefix(self.maxCount))
                    Haptic.trigger(.heavy)
                } else {
                    Haptic.trigger()
                }
                self.textCount = "\(textCount)/\(self.maxCount)"
            }
            .store(in: &cancellables)
        
        $date
            .compactMap { [weak self] date in
                return self?.dateFormatter.string(from: date)
            }
            .sink { [weak self] dateString in
                self?.dateString = dateString
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("\(String(describing: self)) deinit")
    }
    
    func saveReceipt() {
        guard text.isEmpty == false else { return }
        
        do {
            if case let .edit(item) = inputMode {
                let editItem = ReceiptItem(id: item.id, text: text, date: date)
                try provider.update(editItem)
                listener?.didUpdateReceipt(editItem)
            } else {
                var receiptItem = ReceiptItem(text: text, date: date)
                let newId = try provider.create(receiptItem: receiptItem)
                receiptItem.id = newId
                listener?.didSaveRecipt(receiptItem)
            }
            
        } catch {
            message = error.dataErrorDescription
        }
    }
    
    func deleteReceipt() {
        alert = AlertModel(
            message: "이 항목을 지울까요?",
            confirmButton: .init(
                title: "네",
                action: { [weak self] in
                    self?.delete()
                }
            ),
            cancelButton: .init(
                title: "아니요"
            )
        )
    }
    
    private func delete() {
        if case let .edit(item) = inputMode, let id = item.id {
            do {
                try provider.delete(id: id)
                listener?.didDeleteReceipt(item)
            } catch {
                message = error.dataErrorDescription
            }
        }
    }
}

extension ReceiptInputModel {
    enum InputMode: Equatable {
        case create
        case edit(_ model: ReceiptItem)
    }
}
