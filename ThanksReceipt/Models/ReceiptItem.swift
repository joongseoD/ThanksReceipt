//
//  ReceiptItem.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import Foundation

struct ReceiptItem: Codable {
    var id: UUID
    var text: String
    var date: Date
}
