//
//  ReceiptItem.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import Foundation

struct ReceiptItem: Identifiable, Codable {
    var id: String
    var text: String
    var date: Date
    
    init(text: String, date: Date) {
        self.id = UUID().uuidString
        self.text = text
        self.date = date
    }
}
