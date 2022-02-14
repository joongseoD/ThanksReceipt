//
//  ReceiptItemModel.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/12.
//

import SwiftUI

struct ReceiptSectionModel {
    var header: ReceiptItemModel
    var items: [ReceiptItemModel]
    
    var text: String { header.text }
    var countString: String { "\(count).00" }
    var count: Int { items.count + 1 }
    var date: String { header.date }
}


struct ReceiptItemModel: Hashable {
    var id: String
    var date: String
    var text: String
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d(E)"
        dateFormatter.locale = Locale(identifier: "ko")
        return dateFormatter
    }()
    
    init(id: String, date: String, text: String) {
        self.id = id
        self.date = date
        self.text = text
        setup()
    }
    
    init(model: ReceiptItem) {
        guard let id = model.id else { fatalError("there's no id.") }
        self.id = id
        self.text = model.text
        self.date = dateFormatter.string(from: model.date)
        
        setup()
    }
    
    private func setup() {
        
    }
}
