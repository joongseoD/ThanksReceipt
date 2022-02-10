//
//  ThanksReceiptTests.swift
//  ThanksReceiptTests
//
//  Created by Damor on 2022/02/08.
//

import XCTest
import Combine

@testable import ThanksReceipt

class ThanksReceiptTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable>!
    override func setUpWithError() throws {
        self.cancellables = .init()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let items = CurrentValueSubject<[ReceiptItem], Never>([
            .init(text: "1", date: Date()),
            .init(text: "2", date: Date()),
            .init(text: "3", date: Date()),
            .init(text: "4", date: Date()),
            .init(text: "5", date: Date()),
            .init(text: "6", date: Date()),
            .init(text: "7", date: Date()),
            .init(text: "8", date: Date()),
            .init(text: "9", date: Date()),
            .init(text: "10", date: Date()),
            .init(text: "11", date: Date()),
        ])
        
        var pageItems: [ReceiptItem] = []
        let sut = PagingController<ReceiptItem>(items: items.eraseToAnyPublisher(), size: 10)
        sut.pageItems
            .sink { items in
                pageItems += items
            }
            .store(in: &cancellables)
        
        XCTAssertEqual(sut.pageCount, 2)
        XCTAssertEqual(pageItems.count, 10)
        sut.next()
        XCTAssertEqual(pageItems.count, 11)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
