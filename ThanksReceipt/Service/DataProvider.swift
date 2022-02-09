//
//  DataProvider.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import Foundation

final class DataProvider: DataProviding {
    
    func create(receiptItem: ReceiptItem) async throws -> Bool {
        return true
    }
    
    func receiptItemList(page: Int, pageCount: Int = 10) async throws -> [ReceiptItem] {
        return []
    }
    
    func update(id: String, _ item: ReceiptItem) async throws -> Bool {
        return true
    }
    
    func delete(id: String) async throws -> Bool {
        return true
    }
}
