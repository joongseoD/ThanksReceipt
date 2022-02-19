//
//  PagingItem.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/09.
//

import Foundation
import Combine
import CombineExt

struct PagingItems<Item>: Hashable & Equatable where Item: Hashable & Equatable {
    let page: Int
    let pageCount: Int
    var items: [Item]
    
    var isFirstPage: Bool { page == 0 }
    var isLastPage: Bool { page == pageCount }
}

final class PagingController<Item> {
    private let page = CurrentValueSubject<Int, Never>(1)
    private let _pageItems = PassthroughSubject<[Item], Never>()
    private let nextPage = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    var pageItems: AnyPublisher<[Item], Never> { _pageItems.eraseToAnyPublisher() }
    var pageCount: Int = 0
    let size: Int
    
    init(items: AnyPublisher<[Item], Never>, size: Int) {
        self.size = size
        
        items
            .sink { [weak self] items in
                guard let self = self, self.size > 0 else { return }
                self.pageCount = Int((Double(items.count) / Double(self.size)).rounded(.up))
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(page, items)
            .map { [weak self] (page, items) -> [Item] in
                guard let self = self else { return [] }
                let upperBound = min(page * self.size, items.count)
                return Array(items[0..<upperBound])
            }
            .sink { [weak self] in self?._pageItems.send($0) }
            .store(in: &cancellables)
    }
    
    func fetchNext() {
        let nextPage = page.value + 1
        guard nextPage <= pageCount else { return }
        page.send(nextPage)
    }
}
