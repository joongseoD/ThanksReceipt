//
//  DataProviding.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import Foundation

protocol DataProviding {
    func create(receiptItem: ReceiptItem) async throws -> Bool
    
    func receiptItemList() async throws -> [ReceiptItem]
    
    func update(id: String, _ item: ReceiptItem) async throws -> Bool
    
    func delete(id: String) async throws -> Bool
}
