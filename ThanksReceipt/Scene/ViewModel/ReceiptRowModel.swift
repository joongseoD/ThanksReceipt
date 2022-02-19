//
//  ReceiptRowModel.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/12.
//

import SwiftUI

struct ReceiptSectionModel: Equatable {
    var header: ReceiptRowModel
    var items: [ReceiptRowModel]
    
    var text: String { header.text }
    var countString: String { "\(count).00" }
    var count: Int { items.count + 1 }
    var dateString: String { header.dateString }
    var date: Date { header.date }
}

extension ReceiptSectionModel: Comparable {
    static func < (lhs: ReceiptSectionModel, rhs: ReceiptSectionModel) -> Bool {
        return lhs.date < rhs.date
    }
}

struct ReceiptRowModel: Hashable {
    var id: String
    var dateString: String
    var date: Date
    var text: String
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d(E)"
        dateFormatter.locale = Locale(identifier: "ko")
        return dateFormatter
    }()
    
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
