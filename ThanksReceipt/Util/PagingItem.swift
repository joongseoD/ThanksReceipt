//
//  PagingItem.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/09.
//

import Foundation
import Combine
import CombineExt

struct PagingItems<Item> {
    let page: Int
    let pageCount: Int
    var items: [Item]
    
    var isFirstPage: Bool { page == 0 }
    var isLastPage: Bool { page == pageCount }
}

extension PagingItems: Hashable & Equatable where Item: Hashable & Equatable { }

final class PagingController<Item> {
    private let items: AnyPublisher<[Item], Never>
    private let page = CurrentValueSubject<Int, Never>(0)
    private let _pageItems = PassthroughSubject<[Item], Never>()
    private let nextPage = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    var pageItems: AnyPublisher<[Item], Never> { _pageItems.eraseToAnyPublisher() }
    
    var pageCount: Int = 0
    
    var size: Int
    
    init(items: AnyPublisher<[Item], Never>, size: Int) {
        self.items = items
        self.size = size
        
        setup()
    }

    private func setup() {
        items
            .sink { [weak self] items in
                guard let self = self, self.size > 0 else { return }
                print("## count1", items.count)
                self.pageCount = Int((Double(items.count) / Double(self.size)).rounded(.up))
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(page, items)
            .filter { $1.isEmpty == false }
            .map { [weak self] (page, items) -> [Item] in
                guard let self = self else { return [] }
                let lowerBound = page * self.size
                guard page <= self.pageCount, lowerBound < items.count else { return [] }
                
                var upperBound = min(lowerBound + self.size, items.count)
                upperBound = max(upperBound, lowerBound)
                return Array(items[lowerBound..<upperBound])
            }
            .sink { [weak self] in
                self?._pageItems.send($0)
            }
            .store(in: &cancellables)
    }
    
    func next() {
        let nextPage = page.value + 1
        guard nextPage <= pageCount else { return }
        page.send(nextPage)
    }
}
