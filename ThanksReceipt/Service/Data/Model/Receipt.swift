//
//  Receipt.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/09.
//

import RealmSwift

class Receipt: Object {
    @Persisted(primaryKey: true) var id: String?
    @Persisted var text: String = ""
    @Persisted var date: Date?
    @Persisted var createdDate: Date?
    
    convenience init(id: String? = nil, text: String = "", date: Date? = nil, createdDate: Date? = nil) {
        self.init()
        self.id = id ?? UUID().uuidString
        self.text = text
        self.date = date
        self.createdDate = createdDate
    }
    
    convenience init(model: ReceiptItem) {
        self.init()
        self.id = model.id
        self.text = model.text
        self.date = model.date
    }
}
