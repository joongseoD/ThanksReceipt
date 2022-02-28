//
//  TestMockDataProvider.swift
//  ThanksReceiptTests
//
//  Created by Damor on 2022/02/28.
//

import Combine
import CombineSchedulers
@testable import ThanksReceipt

final class TestMockDataProvider: DataProviding {
    private let mockProvider = MockDataProvider()
    var receiptItems: CurrentValueSubject<[ReceiptItem], Error> {
        mockProvider.receiptList.send([])
        return mockProvider.receiptList
    }
    
    var createCallCount = 0
    var receiptItemListCallCount = 0
    var receiptItemListDate: Date?
    var updateCallCount = 0
    var deleteIdCallCount = 0
    var deleteDateCallCount = 0
    var deleteDate: Date?
    
    func create(receiptItem: ReceiptItem) throws -> String? {
        createCallCount += 1
        return try mockProvider.create(receiptItem: receiptItem)
    }
    
    func receiptItemList(in date: Date) -> AnyPublisher<[ReceiptItem], Error> {
        receiptItemListCallCount += 1
        receiptItemListDate = date
        return mockProvider.receiptItemList(in: date).eraseToAnyPublisher()
    }
    
    func update(_ item: ReceiptItem) throws {
        updateCallCount += 1
        return try mockProvider.update(item)
    }
    
    func delete(id: String) throws {
        deleteIdCallCount += 1
        return try mockProvider.delete(id: id)
    }
    
    func delete(date: Date) throws {
        deleteDateCallCount += 1
        deleteDate = date
        return try mockProvider.delete(date: date)
    }
}
