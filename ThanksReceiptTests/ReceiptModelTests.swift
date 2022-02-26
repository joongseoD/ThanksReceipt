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

final class MockRootComponents: ReceiptModelDependency {
    var mock: Bool = false
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
    var createCallCount = 0
    var receiptItemListCallCount = 0
    var updateCallCount = 0
    
    func create(receiptItem: ReceiptItem) throws -> String? {
        createCallCount += 1
        var items = receiptItems.value
        var newItem = receiptItem
        newItem.id = newItem.text
        items.append(newItem)
        receiptItems.send(items)
        
        return receiptItem.id
    }
    
    func receiptItemList(in date: Date) -> AnyPublisher<[ReceiptItem], Error> {
        receiptItemListCallCount += 1
        return receiptItems.eraseToAnyPublisher()
    }
    
    func update(_ item: ReceiptItem) throws {
        updateCallCount += 1
    }
    
    func delete(id: String) throws {
     
    }
    
    func delete(date: Date) throws {
     
    }
}

final class ReceiptModelTests: XCTestCase {
    private var provider: TestMockDataProvider!
    private var dependency: MockRootComponents!
    private var sut: ReceiptModel!
    private var scheduler: AnySchedulerOf<DispatchQueue>!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        
        provider = TestMockDataProvider()
        scheduler = .immediate
        dependency = MockRootComponents(
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
//        XCTAssertEqual(sut.scrollToId, "1")
    }
    
    // update month with listener
    func testUpdateReceiptDate() {
        // Given
        let monthPickerModel = MonthPickerModel(
            dependency: MonthPickerModelComponents(currentDate: Date()),
            listener: sut
        )
        monthPickerModel.didSelectYear("2020")
        monthPickerModel.didSelectMonth("Jan")
        monthPickerModel.didTapComplete()
        
        // When
        let resultYear = DateFormatter(format: .year).string(from: sut.selectedMonth)
        let resultMonth = DateFormatter(format: .shortMonth).string(from: sut.selectedMonth)
        
        // Then
        let expect = DateFormatter(format: .longMonth).string(from: sut.selectedMonth)
        XCTAssertEqual(resultYear, "2020")
        XCTAssertEqual(resultMonth, "Jan")
        XCTAssertEqual(sut.message, "Hello, \(expect).")
        XCTAssertEqual(provider.receiptItemListCallCount, 2)
    }
    
    // message & alert
    
    // input did save / update / delete
    func testProcessOfAfterSaving() {
        // Given
        let inputModel = ReceiptInputModel(
            dependency: ReceiptInputModelComponents(
                dependency: dependency,
                mode: .create,
                date: Date()),
            listener: sut
        )
        
        inputModel.text = "test"
        inputModel.date = Date()
        
        // When
        inputModel.saveReceipt()
        
        // Then
        XCTAssertEqual(sut.scrollToId, nil)
        XCTAssertEqual(sut.message, "감사합니다 :)")
        XCTAssertEqual(provider.receiptItemListCallCount, 2)
    }
    
    func testProcessOfAfterEditing() {
        // Given
        let editingReceipt = ReceiptItem(
            id: "id",
            text: "text",
            date: Date()
        )
        let selectedDate = Date()
        let inputModel = ReceiptInputModel(
            dependency: ReceiptInputModelComponents(
                dependency: dependency,
                mode: .edit(
                    editingReceipt
                ),
                date: selectedDate
            ),
            listener: sut
        )
        let dateFormatter = DateFormatter(format: .yearMonthDay)
        
        // When
        inputModel.saveReceipt()
        inputModel.text = "new text"
        inputModel.date = dateFormatter.date(from: "2022.02.24")!
        
        // Then
        XCTAssertEqual(sut.message, "감사합니다 :)")
        XCTAssertEqual(provider.receiptItemListCallCount, 2)
        XCTAssertEqual(provider.updateCallCount, 1)
        XCTAssertEqual(dateFormatter.string(from: sut.selectedMonth), dateFormatter.string(from: selectedDate))
    }
    
    // service
    
    // deletingdate
    func testDeleteReceiptsOfDay() {
        // Given
        let deletingDate = PassthroughSubject<Date, Never>()
        let service = ReceiptModelService(
            dependency: ReceiptModelServiceComponents(
                provider: provider,
                pageSize: dependency.pageSize,
                scheduler: dependency.mainScheduler,
                selectedDate: Empty().eraseToAnyPublisher(),
                deletingDate: deletingDate,
                reload: Empty().eraseToAnyPublisher())
        )
        
        provider.receiptItems.send([
            ReceiptItem(id: "1", text: "", date: Date()),
            ReceiptItem(id: "2", text: "", date: Date()),
            ReceiptItem(id: "3", text: "", date: Date())
        ])
        
        
        // When
        
        // Then
    }
    
    
    func testViewStateWhen() {
        sut.didTapSave()
        
//        XCTAssertEqual(sut.viewState, .snapshotPreview)
    }
}
