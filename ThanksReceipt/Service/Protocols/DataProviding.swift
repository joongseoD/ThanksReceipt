//
//  DataProviding.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import Foundation
import Combine

protocol DataProviding {
    func create(receiptItem: ReceiptItem) throws
    
    func receiptItemList(in date: Date) -> AnyPublisher<[ReceiptItem], Error>
    
    func update(_ item: ReceiptItem) throws
    
    func delete(id: String) throws
}
