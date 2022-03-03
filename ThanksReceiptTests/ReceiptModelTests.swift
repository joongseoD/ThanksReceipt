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

final class ReceiptModelTests: XCTestCase {
    private var provider: TestMockDataProvider!
    private var dependency: TestMockRootComponents!
    private var service: ReceiptModelService!
    private var sut: ReceiptModel!
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
        service = ReceiptModelService(dependency: dependency)
        sut = ReceiptModel(
            dependency: dependency,
            service: service
        )
        cancellables = .init()
    }
    
    override func tearDown() {
        super.tearDown()
        
        cancellables = nil
        sut = nil
        service = nil
        scheduler = nil
        provider = nil
        dependency = nil
    }
    
    func testReceiptSectionModelsWhenGivingReceiptItems() {
        // given
        let item = ReceiptItem(id: "1", text: "", date: Date())
        provider.receiptItems.send([
            item,
            ReceiptItem(id: "2", text: "", date: Date()),
            ReceiptItem(id: "3", text: "", date: Date())
        ])
        
        // when
        let sectionModels = sut.receiptItems
        
        // then
        XCTAssertEqual(sectionModels.count, 1)
        XCTAssertEqual(sectionModels.itemsCount, 3)
        XCTAssertEqual(sectionModels.first!.header, ReceiptRowModel(model: item))
        XCTAssertEqual(sectionModels.first?.items.count, 2)
        XCTAssertEqual(sut.totalCount, sectionModels.totalCount)
        XCTAssertEqual(provider.receiptItemListCallCount, 1)
    }
    
    func testUpdateReceiptDate() {
        // Given
        let monthPickerModel = MonthPickerModel(
            dependency: MonthPickerModelComponents(currentDate: .init(Date())),
            listener: sut
        )
        monthPickerModel.didSelectYear("2020")
        monthPickerModel.didSelectMonth("Jan")
        monthPickerModel.didTapComplete()
        
        // When
        let resultYear = DateFormatter(format: .year).string(from: sut.selectedMonth!)
        let resultMonth = DateFormatter(format: .shortMonth).string(from: sut.selectedMonth!)
        
        // Then
        let expect = DateFormatter(format: .longMonth).string(from: sut.selectedMonth!)
        XCTAssertEqual(resultYear, "2020")
        XCTAssertEqual(resultMonth, "Jan")
        XCTAssertEqual(sut.message, "Hello, \(expect).")
        XCTAssertEqual(provider.receiptItemListCallCount, 2)
    }
    
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
        XCTAssertEqual(sut.message, "감사가 기록됐어요.")
        XCTAssertEqual(provider.receiptItemListCallCount, 2)
    }
    
    func testEditViewStateWhenRowTapped() {
        // Given
        let findingItem = ReceiptItem(id: "id2", text: "", date: Date())
        provider.receiptItems.send([
            ReceiptItem(id: "id1", text: "", date: Date()),
            findingItem,
            ReceiptItem(id: "id3", text: "", date: Date())
        ])
        
        let inputComponent = ReceiptInputModelComponents(
            dependency: dependency,
            mode: .edit(findingItem)
        )
        
        // When
        sut.didTapRow("id2")
        
        // Then
        XCTAssertEqual(sut.viewState, .input(inputComponent))
    }
    
    func testProcessOfAfterEditing() {
        // Given
        let editingReceipt = ReceiptItem(
            id: "id",
            text: "text",
            date: Date()
        )
        
        provider.receiptItems.send([
            editingReceipt,
            ReceiptItem(id: "1", text: "", date: Date())
        ])
        
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
        inputModel.text = "new text"
        inputModel.date = dateFormatter.date(from: "2022.02.24")!
        inputModel.saveReceipt()
        
        // Then
        XCTAssertEqual(sut.message, "감사가 기록됐어요.")
        XCTAssertEqual(provider.receiptItemListCallCount, 2)
        XCTAssertEqual(provider.updateCallCount, 1)
        XCTAssertEqual(dateFormatter.string(from: sut.selectedMonth!), dateFormatter.string(from: selectedDate))
        XCTAssertEqual(sut.receiptItems.first?.header.text, "new text")
    }
    
    func testDeleteReceiptsOfDay() {
        // Given
        let dateFormatter = DateFormatter(format: .yearMonthDay)
        let date = dateFormatter.date(from: "2022.01.01")!
        
        provider.receiptItems.send([
            ReceiptItem(id: "1", text: "", date: Date()),
            ReceiptItem(id: "2", text: "", date: date),
            ReceiptItem(id: "3", text: "", date: date)
        ])
        
        // When
        dependency.deletionDate.send(date)
        sut.alert?.confirmButton.action?()
        
        // Then
        XCTAssertNotNil(sut.alert)
        XCTAssertEqual(provider.deleteDateCallCount, 1)
        XCTAssertEqual(provider.receiptItemListCallCount, 2)
        XCTAssertEqual(sut.receiptItems.itemsCount, 1)
    }
    
    func testProcessOfAfterDeleting() {
        // Given
        let deletingReceipt = ReceiptItem(
            id: "id",
            text: "text",
            date: Date()
        )
        provider.receiptItems.send([
            deletingReceipt,
            ReceiptItem(id: "1", text: "", date: Date())
        ])
        
        let inputModel = ReceiptInputModel(
            dependency: ReceiptInputModelComponents(
                dependency: dependency,
                mode: .edit(
                    deletingReceipt
                ),
                date: Date()
            ),
            listener: sut
        )
        
        // When
        inputModel.deleteReceipt()
        inputModel.alert?.confirmButton.action?()
        
        // Then
        XCTAssertNotNil(inputModel.alert)
        XCTAssertEqual(provider.receiptItemListCallCount, 2)
        XCTAssertEqual(provider.deleteIdCallCount, 1)
        XCTAssertEqual(sut.receiptItems.first?.header.id, "1")
    }
    
    func testNilViewStateWhenBackgroundTapped() {
        // Given
        sut.viewState = .monthPicker(
            MonthPickerModelComponents(currentDate: .init(Date()))
        )
        
        // When
        sut.didTapBackgroundView()
        
        // Then
        XCTAssertNil(sut.viewState)
    }
    
    func testSelectedMonthWhenDateSelected() {
        // Given
        let dateFormatter = DateFormatter(format: .longMonth)
        let selectingDate = dateFormatter.date(from: "February")!
        
        // When
        sut.didSelectDate(selectingDate)
        
        // Then
        XCTAssertEqual(sut.monthText, "February")
        XCTAssert(sut.message!.hasPrefix("Hello,"))
        XCTAssertEqual(provider.receiptItemListCallCount, 2)
    }
    
    func testSelectedMonthWhenAllSelected() {
        // When
        sut.didSelectDate(nil)
        
        // Then
        XCTAssertEqual(sut.monthText, "All")
        XCTAssert(sut.message!.hasPrefix("Hello,"))
        XCTAssertEqual(provider.receiptItemListCallCount, 2)
    }
}
