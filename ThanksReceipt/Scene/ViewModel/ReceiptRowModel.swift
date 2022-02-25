//
//  ReceiptRowModel.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/12.
//

import SwiftUI
import Combine

protocol ReceiptSectionModelDependency {
    var tappedDateSubject: PassthroughSubject<Date, Never>? { get }
}

struct ReceiptSectionModelComponents: ReceiptSectionModelDependency {
    var tappedDateSubject: PassthroughSubject<Date, Never>?
}

struct ReceiptSectionModel {
    var header: ReceiptRowModel
    var items: [ReceiptRowModel]
    var text: String { header.text }
    var countString: String { "\(count).00" }
    var count: Int { items.count + 1 }
    var dateString: String { header.dateString }
    var date: Date { header.date }
    
    private var _tappedDate: PassthroughSubject<Date, Never>?
    
    var tappedDate: AnyPublisher<Date, Never> {
        guard let _tappedDate = _tappedDate else {
            return Empty<Date, Never>().eraseToAnyPublisher()
        }

        return _tappedDate.eraseToAnyPublisher()
    }
    
    init(header: ReceiptRowModel,
         items: [ReceiptRowModel],
         dependency: ReceiptSectionModelDependency = ReceiptSectionModelComponents()) {
        self.header = header
        self.items = items
        self._tappedDate = dependency.tappedDateSubject
    }
    
    func didTapDate() {
        _tappedDate?.send(date)
    }
}

extension ReceiptSectionModel: Equatable {
    static func == (lhs: ReceiptSectionModel, rhs: ReceiptSectionModel) -> Bool {
        lhs.header == rhs.header &&
        lhs.items == rhs.items
    }
}

extension ReceiptSectionModel: Comparable {
    static func < (lhs: ReceiptSectionModel, rhs: ReceiptSectionModel) -> Bool {
        return lhs.date < rhs.date
    }
}

struct ReceiptRowModel: Equatable {
    var id: String
    var dateString: String
    var date: Date
    var text: String
    
    private let dateFormatter = DateFormatter(format: .shortMonthDayWeek)
    
    init(id: String, dateString: String, date: Date, text: String) {
        self.id = id
        self.dateString = dateString
        self.text = text
        self.date = date
    }
    
    init(model: ReceiptItem) {
        guard let id = model.id else { fatalError("there's no id.") }
        self.id = id
        self.text = model.text
        self.dateString = dateFormatter.string(from: model.date)
        self.date = model.date
    }
}
