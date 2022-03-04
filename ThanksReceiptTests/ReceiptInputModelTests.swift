//
//  ReceiptInputModelTests.swift
//  ThanksReceiptTests
//
//  Created by Damor on 2022/02/28.
//

import XCTest
import Combine
import CombineSchedulers
@testable import ThanksReceipt

final class TestMockReceiptInputModelComponents: ReceiptInputModelDependency {
    var provider: DataProviding
    var mainScheduler: AnySchedulerOf<DispatchQueue>
    var mode: ReceiptInputModel.InputMode
    var date: Date
    
    init(
        provider: DataProviding,
        mainScheduler: AnySchedulerOf<DispatchQueue> = .immediate,
        mode: ReceiptInputModel.InputMode,
        date: Date
    ) {
        self.provider = provider
        self.mainScheduler = mainScheduler
        self.mode = mode
        self.date = date
    }
}

final class TestReceiptInputModelListener: ReceiptInputModelListener {
    var item: ReceiptItem?
    
    func didSaveRecipt(_ item: ReceiptItem) {
        self.item = item
    }
    
    func didUpdateReceipt(_ item: ReceiptItem) {
        self.item = item
    }
    
    func didDeleteReceipt(_ item: ReceiptItem) {
        self.item = item
    }
}

final class ReceiptInputModelTests: XCTestCase {
    private var provider: TestMockDataProvider!
    private var listener: TestReceiptInputModelListener!
    private var scheduler: AnySchedulerOf<DispatchQueue>!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        
        provider = TestMockDataProvider()
        scheduler = .immediate
        listener = TestReceiptInputModelListener()
        cancellables = .init()
    }
    
    override func tearDown() {
        super.tearDown()
        
        cancellables = nil
        scheduler = nil
        provider = nil
    }
    
    func testCreateMode() {
        // given
        let currentDate = DateFormatter(format: .yearMonthDay).date(from: "2022.7.17")
        let dependency = TestMockReceiptInputModelComponents(
            provider: provider,
            mode: .create,
            date: currentDate!
        )
        let sut = ReceiptInputModel(
            dependency: dependency,
            listener: nil
        )
        
        // then
        XCTAssert(sut.dateString.hasPrefix("7월 17일"))
        XCTAssertEqual(sut.textCount, "0/\(Constants.inputMaxLength)")
    }
    
    func testEditMode() {
        // given
        let formatter = DateFormatter(format: .yearMonthDay)
        let receiptItem = ReceiptItem(
            id: "id",
            text: "text1",
            date: formatter.date(from: "2022.7.16")!
        )
        let dependency = TestMockReceiptInputModelComponents(
            provider: provider,
            mode: .edit(receiptItem),
            date: formatter.date(from: "2022.7.17")!
        )
        let sut = ReceiptInputModel(
            dependency: dependency,
            listener: nil
        )
        
        // then
        XCTAssert(sut.dateString.hasPrefix("7월 16일"))
        XCTAssertEqual(sut.textCount, "\(receiptItem.text.count)/\(Constants.inputMaxLength)")
    }
    
    func testTextCount() {
        // given
        let currentDate = DateFormatter(format: .yearMonthDay).date(from: "2022.7.17")
        let dependency = TestMockReceiptInputModelComponents(
            provider: provider,
            mode: .create,
            date: currentDate!
        )
        let sut = ReceiptInputModel(
            dependency: dependency,
            listener: nil
        )
        
        // when
        sut.text = "input text"
        
        // then
        XCTAssertEqual(sut.text.count, 10)
        XCTAssertEqual(sut.textCount, "10/\(Constants.inputMaxLength)")
    }
    
    func testSaveReceipt() {
        // given
        let currentDate = DateFormatter(format: .yearMonthDay).date(from: "2022.7.17")
        let dependency = TestMockReceiptInputModelComponents(
            provider: provider,
            mode: .create,
            date: currentDate!
        )
        let sut = ReceiptInputModel(
            dependency: dependency,
            listener: listener
        )
        
        // when
        sut.text = "text1"
        sut.saveReceipt()
        
        // then
        XCTAssertEqual(provider.createCallCount, 1)
        XCTAssertEqual(listener.item?.text, "text1")
        XCTAssertEqual(listener.item?.date, currentDate)
    }
    
    func testEditReceipt() {
        // given
        let formatter = DateFormatter(format: .yearMonthDay)
        let receiptItem = ReceiptItem(
            id: "id",
            text: "text1",
            date: formatter.date(from: "2022.7.16")!
        )
        provider.receiptItems.send([receiptItem])
        
        let dependency = TestMockReceiptInputModelComponents(
            provider: provider,
            mode: .edit(receiptItem),
            date: formatter.date(from: "2022.7.17")!
        )
        let sut = ReceiptInputModel(
            dependency: dependency,
            listener: listener
        )
        
        // when
        sut.text = "new text"
        sut.saveReceipt()
        
        // then
        XCTAssertEqual(provider.updateCallCount, 1)
        XCTAssertEqual(listener.item?.text, "new text")
        XCTAssertEqual(listener.item?.date, receiptItem.date)
    }
    
    func testDeleteReceipt() {
        // given
        let formatter = DateFormatter(format: .yearMonthDay)
        let receiptItem = ReceiptItem(
            id: "id",
            text: "text1",
            date: formatter.date(from: "2022.7.16")!
        )
        provider.receiptItems.send([receiptItem])
        
        let dependency = TestMockReceiptInputModelComponents(
            provider: provider,
            mode: .edit(receiptItem),
            date: formatter.date(from: "2022.7.17")!
        )
        let sut = ReceiptInputModel(
            dependency: dependency,
            listener: listener
        )
        
        // when
        sut.deleteReceipt()
        sut.alert?.confirmButton.action?()
        
        // then
        XCTAssertEqual(provider.deleteIdCallCount, 1)
        XCTAssertEqual(provider.receiptItems.value.count, 0)
        XCTAssertEqual(listener.item?.id, "id")
    }
}

