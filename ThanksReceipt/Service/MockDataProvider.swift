//
//  MockDataProvider.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/23.
//

import Foundation
import Combine

final class MockDataProvider: DataProviding {
    private let receiptList = CurrentValueSubject<[ReceiptItem], Error>([
        .init(id: UUID().uuidString, text: "안녕하세요", date: Date()),
        .init(id: UUID().uuidString, text: "안녕하세요", date: Date()),
        .init(id: UUID().uuidString, text: "안녕하세요", date: Date()),
        .init(id: UUID().uuidString, text: "안녕하세요", date: Date()),
        .init(id: UUID().uuidString, text: "안녕하세요", date: Date())
    ])
    
    func create(receiptItem: ReceiptItem) throws -> String? {
        var item = receiptItem
        item.id = UUID().uuidString
        var values = receiptList.value
        values.append(item)
        receiptList.send(values)
        return item.id
    }
    
    func receiptItemList(in date: Date) -> AnyPublisher<[ReceiptItem], Error> {
        return receiptList.share(replay: 1).eraseToAnyPublisher()
    }
    
    func update(_ item: ReceiptItem) throws {
        throw DataError.custom("not supported")
    }
    
    func delete(id: String) throws {
        throw DataError.custom("not supported")
    }
}
