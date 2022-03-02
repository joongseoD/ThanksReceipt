//
//  MonthPickerModelTests.swift
//  ThanksReceiptTests
//
//  Created by Damor on 2022/02/28.
//

import XCTest
import Combine
import CombineSchedulers
@testable import ThanksReceipt

final class TestMonthPickerModelComponents: MonthPickerModelDependency {
    var currentDate: CurrentValueSubject<Date, Never> = .init(Date())
}

final class TestMonthPickerModelListener: MonthPickerModelListener {
    var selectedDate: Date?
    func didSelectDate(_ date: Date) {
        selectedDate = date
    }
}

final class MonthPickerModelTests: XCTestCase {
    private var dependency: TestMonthPickerModelComponents!
    private var sut: MonthPickerModel!
    private var listener: TestMonthPickerModelListener!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        
        listener = TestMonthPickerModelListener()
        dependency = TestMonthPickerModelComponents()
        sut = MonthPickerModel(dependency: dependency, listener: listener)
        cancellables = .init()
    }
    
    override func tearDown() {
        super.tearDown()
        
        cancellables = nil
        sut = nil
        listener = nil
        dependency = nil
    }
    
    func testSetupDatesWhenDidAppear() {
        // Given
        let formatter = DateFormatter(format: .yearMonthDay)
        let date = formatter.date(from: "2022.03.01")!
        dependency.currentDate.send(date)
        
        // When
        sut.didAppear()
        
        // Then
        let expectedMonths = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let expectedYears = ["2022", "2021", "2020", "2019", "2018", "2017", "2016", "2015", "2014", "2013", "2012", "2011"]
        XCTAssertEqual(sut.months, expectedMonths)
        XCTAssertEqual(sut.years, expectedYears)
        XCTAssertEqual(sut.selectedYear, "2022")
        XCTAssertEqual(sut.selectedMonth, "Mar")
    }
    
    func testChangeDate() {
        // Given
        let formatter = DateFormatter(format: .yearMonthDay)
        let date = formatter.date(from: "2022.03.01")!
        dependency.currentDate.send(date)
        
        // When
        sut.didSelectYear("2021")
        sut.didSelectMonth("Jan")
        sut.didTapComplete()
        
        // Then
        XCTAssertEqual(sut.selectedYear, "2021")
        XCTAssertEqual(sut.selectedMonth, "Jan")
        XCTAssertEqual(listener!.selectedDate, formatter.date(from: "2021.01.01"))
    }
    
    func testResetDate() {
        // Given
        let formatter = DateFormatter(format: .yearMonthDay)
        let date = Date()
        dependency.currentDate.send(date)
        sut.didSelectYear("2021")
        sut.didSelectMonth("Jan")
        
        // When
        sut.reset()
        
        // Then
        XCTAssertEqual(formatter.string(from: listener!.selectedDate!), formatter.string(from: date))
    }
}
