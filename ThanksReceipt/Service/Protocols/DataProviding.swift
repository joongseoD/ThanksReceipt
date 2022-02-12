//
//  DataProviding.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import Combine

protocol DataProviding {
    func create(receiptItem: ReceiptItem) throws
    
    func receiptItemList() -> AnyPublisher<[ReceiptItem], Error>
    
    func update(_ item: ReceiptItem) throws
    
    func delete(id: String) throws
}
