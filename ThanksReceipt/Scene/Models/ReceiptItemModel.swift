//
//  ReceiptItemModel.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/12.
//

import SwiftUI

struct ReceiptItemModel {
    var id: String
    var date: String
    var text: String
    var count: String = ""
    var isSubItem: Bool = false
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d(E)"
        dateFormatter.locale = Locale(identifier: "ko")
        return dateFormatter
    }()
    
    var topPadding: CGFloat {
        isSubItem ? 0 : 10
    }
    
    init(id: String, date: String, text: String, count: String, isSubItem: Bool = false) {
        self.id = id
        self.date = date
        self.text = text
        self.count = count
        self.isSubItem = isSubItem
        setup()
    }
    
    init(model: ReceiptItem, isSubItem: Bool = false) {
        guard let id = model.id else { fatalError("there's no id.") }
        self.id = id
        self.text = model.text
        self.count = ""
        self.date = dateFormatter.string(from: model.date)
        self.isSubItem = isSubItem
        
        setup()
    }
    
    private func setup() {
        
    }
}
