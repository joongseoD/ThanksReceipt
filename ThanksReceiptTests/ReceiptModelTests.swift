//
//  ReceiptModelTest.swift
//  ThanksReceiptTests
//
//  Created by Damor on 2022/02/23.
//

import XCTest
import Combine
import CombineSchedulers
@testable import ThanksReceipt

final class MockReceiptModelComponents: ReceiptModelDependency {
    var mainScheduler: AnySchedulerOf<DispatchQueue>
    var provider: DataProviding
    var pageSize: Int
    
    init(provider: DataProviding, mainScheduler: AnySchedulerOf<DispatchQueue>, pageSize: Int) {
        self.provider = provider
        self.mainScheduler = mainScheduler
        self.pageSize = pageSize
    }
}

final class TestMockDataProvider: DataProviding {
    
    let receiptItems = CurrentValueSubject<[ReceiptItem], Error>([])
    
    var receiptItemListCallCount = 0
    
    func create(receiptItem: ReceiptItem) throws -> String? {
        return nil
    }
    
    func receiptItemList(in date: Date) -> AnyPublisher<[ReceiptItem], Error> {
        receiptItemListCallCount += 1
        return receiptItems.eraseToAnyPublisher()
    }
    
    func update(_ item: ReceiptItem) throws {
     
    }
    
    func delete(id: String) throws {
     
    }
    
    func delete(date: Date) throws {
     
    }
}

final class ReceiptModelTests: XCTestCase {
    private var provider: TestMockDataProvider!
    private var dependency: MockReceiptModelComponents!
    private var sut: ReceiptModel!
    private var scheduler: AnySchedulerOf<DispatchQueue>!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        
        provider = TestMockDataProvider()
        scheduler = .immediate
        dependency = MockReceiptModelComponents(
            provider: provider,
            mainScheduler: scheduler,
            pageSize: 100
        )
        sut = ReceiptModel(dependency: dependency)
        cancellables = .init()
    }
    
    override func tearDown() {
        super.tearDown()
        
        cancellables = nil
        sut = nil
        dependency = nil
    }
    
    func testReceiptSectionModelsWhenGivenReceiptItems() {
        // given
        provider.receiptItems.send([
            ReceiptItem(id: "1", text: "", date: Date()),
            ReceiptItem(id: "2", text: "", date: Date()),
            ReceiptItem(id: "3", text: "", date: Date())
        ])
        
        // when
        let sectionModels = sut.receiptItems
        
        // then
        XCTAssertEqual(sectionModels.count, 1)
        XCTAssertEqual(sectionModels.itemsCount, 3)
        XCTAssertEqual(sut.totalCount, sectionModels.totalCount)
        XCTAssertEqual(provider.receiptItemListCallCount, 1)
        XCTAssertEqual(sut.scrollToId, "1")
    }
    
    func testViewStateWhen() {
        sut.didTapSave()
        
        XCTAssertEqual(sut.viewState, .snapshotPreview)
    }
}
