//
//  ReceiptItem.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import Foundation

struct ReceiptItem: Identifiable, Codable, Equatable {
    var id: String?
    var text: String
    var date: Date
    
    init(id: String? = nil, text: String, date: Date) {
        self.id = id
        self.text = text
        self.date = date
    }
    
    init?(dataModel: Receipt) {
        guard let id = dataModel.id, let date = dataModel.date else { return nil }
        self.id = id
        self.text = dataModel.text
        self.date = date
    }
}

extension ReceiptItem: CustomStringConvertible {
    func asDictionary() -> [String:Any] {
        return [
            "id" : id ?? "",
            "text" : text,
            "date" : date
        ]
    }
    
    var description: String {
        "id: \(id ?? ""), text: \(text), date: \(date)"
    }
}
