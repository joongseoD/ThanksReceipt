//
//  TestMockRootComponents.swift
//  ThanksReceiptTests
//
//  Created by Damor on 2022/02/28.
//

import Foundation
import Combine
import CombineSchedulers
@testable import ThanksReceipt

final class TestMockRootComponents: ReceiptModelDependency, ReceiptModelServiceDependency {
    var mock: Bool = false
    var mainScheduler: AnySchedulerOf<DispatchQueue>
    var provider: DataProviding
    var deletionDate: PassthroughSubject<Date, Never>
    var reload: CurrentValueSubject<Void, Never>
    var backgroundScheduler: AnySchedulerOf<DispatchQueue>
    var selectedDate: CurrentValueSubject<Date?, Never>
    
    init(
        provider: DataProviding,
        mainScheduler: AnySchedulerOf<DispatchQueue>,
        backgroundScheduler: AnySchedulerOf<DispatchQueue>,
        deletionDate: PassthroughSubject<Date, Never> = .init(),
        reload: CurrentValueSubject<Void, Never> = .init(()),
        selectedDate: CurrentValueSubject<Date?, Never> = .init(Date())
    ) {
        self.provider = provider
        self.mainScheduler = mainScheduler
        self.backgroundScheduler = backgroundScheduler
        self.deletionDate = deletionDate
        self.reload = reload
        self.selectedDate = selectedDate
    }
}
