//
//  SectionModelServiceTests.swift
//  ThanksReceiptTests
//
//  Created by Damor on 2022/02/28.
//

import XCTest
import Combine
import CombineSchedulers
@testable import ThanksReceipt

final class SectionModelServiceTests: XCTestCase {
    private var provider: TestMockDataProvider!
    private var dependency: TestMockRootComponents!
    private var sut: ReceiptModelService!
    private var scheduler: AnySchedulerOf<DispatchQueue>!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        
        provider = TestMockDataProvider()
        scheduler = .immediate
        dependency = TestMockRootComponents(
            provider: provider,
            mainScheduler: scheduler,
            backgroundScheduler: scheduler
        )
        sut = ReceiptModelService(dependency: dependency)
        cancellables = .init()
    }
    
    override func tearDown() {
        super.tearDown()
        
        cancellables = nil
        sut = nil
        scheduler = nil
        provider = nil
        dependency = nil
    }
    
    func testSectionModelsWhenGivingModels() {
        // Given
        var sectionModels: [ReceiptSectionModel] = []
        sut.sectionModels
            .sink(receiveValue: { sectionModels = $0 })
            .store(in: &cancellables)
        
        // When
        let formatter = DateFormatter(format: .yearMonthDay)
        let date1 = formatter.date(from: "2022.01.01")!
        let date2 = formatter.date(from: "2022.01.02")!
        let date3 = formatter.date(from: "2022.01.03")!
        
        provider.receiptItems.send([
            ReceiptItem(id: "1", text: "1", date: date1),
            ReceiptItem(id: "2", text: "2", date: date1),
            ReceiptItem(id: "3", text: "3", date: date2),
            ReceiptItem(id: "4", text: "4", date: date3),
            ReceiptItem(id: "5", text: "5", date: date3)
        ])
        
        // Then
        XCTAssertEqual(provider.receiptItemListCallCount, 1)
        XCTAssertEqual(sectionModels.count, 3)
        XCTAssertEqual(sectionModels.itemsCount, 5)
        XCTAssertEqual(sectionModels[0].header.id, "1")
        XCTAssertEqual(sectionModels[0].items.count, 1)
        XCTAssertEqual(sectionModels[1].header.id, "3")
        XCTAssertEqual(sectionModels[1].items.count, 0)
        XCTAssertEqual(sectionModels[2].header.id, "4")
    }
    
    func testFindReceiptItemById() {
        // Given
        let formatter = DateFormatter(format: .yearMonthDay)
        let date1 = formatter.date(from: "2022.01.01")!
        let date2 = formatter.date(from: "2022.01.02")!
        let date3 = formatter.date(from: "2022.01.03")!
        
        var expectedItem: ReceiptItem?
        sut.foundReceiptItem
            .sink { expectedItem = $0 }
            .store(in: &cancellables)
        
        // When
        provider.receiptItems.send([
            ReceiptItem(id: "1", text: "1", date: date1),
            ReceiptItem(id: "2", text: "2", date: date1),
            ReceiptItem(id: "3", text: "3", date: date2),
            ReceiptItem(id: "4", text: "4", date: date3),
            ReceiptItem(id: "5", text: "5", date: date3)
        ])
        
        sut.findReceiptItem(by: "1")
        
        // Then
        XCTAssertEqual(expectedItem!.id, "1")
        XCTAssertEqual(expectedItem!.text, "1")
        XCTAssertEqual(expectedItem!.date, date1)
    }
    
    func testReload() {
        // Given
        var sectionModelsCallCount = 0
        sut.sectionModels
            .sink(receiveValue: { _ in sectionModelsCallCount += 1 })
            .store(in: &cancellables)
        
        // When
        let formatter = DateFormatter(format: .yearMonthDay)
        let date1 = formatter.date(from: "2022.01.01")!
        let date2 = formatter.date(from: "2022.01.02")!
        let date3 = formatter.date(from: "2022.01.03")!
        
        provider.receiptItems.send([
            ReceiptItem(id: "1", text: "1", date: date1),
            ReceiptItem(id: "2", text: "2", date: date1),
            ReceiptItem(id: "3", text: "3", date: date2),
            ReceiptItem(id: "4", text: "4", date: date3),
            ReceiptItem(id: "5", text: "5", date: date3)
        ])
        
        sut.didChangedDate(date3)
        sut.reload()
        
        // Then
        XCTAssertEqual(sectionModelsCallCount, 3)
        XCTAssertEqual(provider.receiptItemListCallCount, 2)
        XCTAssertEqual(provider.receiptItemListDate, date3)
    }
    
    func testDeleteItemsForDate() {
        // Given
        var sectionModels: [ReceiptSectionModel] = []
        sut.sectionModels
            .sink(receiveValue: { sectionModels = $0 })
            .store(in: &cancellables)
       
        let formatter = DateFormatter(format: .yearMonthDay)
        let date1 = formatter.date(from: "2022.01.01")!
        let date2 = formatter.date(from: "2022.01.02")!
        let date3 = formatter.date(from: "2022.01.03")!
        
        provider.receiptItems.send([
            ReceiptItem(id: "1", text: "1", date: date1),
            ReceiptItem(id: "2", text: "2", date: date1),
            ReceiptItem(id: "3", text: "3", date: date2),
            ReceiptItem(id: "4", text: "4", date: date3),
            ReceiptItem(id: "5", text: "5", date: date3)
        ])
     
        try! sut.delete(date3)
        
        // Then
        XCTAssertEqual(provider.deleteDateCallCount, 1)
        XCTAssertEqual(provider.deleteDate, date3)
        XCTAssertEqual(sectionModels.count, 2)
        XCTAssertEqual(sectionModels.itemsCount, 3)
        XCTAssertEqual(sectionModels[0].header.id, "1")
        XCTAssertEqual(sectionModels[0].items.count, 1)
        XCTAssertEqual(sectionModels[1].header.id, "3")
        XCTAssertEqual(sectionModels[1].items.count, 0)
    }
}
