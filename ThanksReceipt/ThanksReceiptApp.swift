//
//  ThanksReceiptApp.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import SwiftUI
import Combine
import CombineSchedulers

@main
struct ThanksReceiptApp: App {
    private let components = AppRootComponents()
    var body: some Scene {
        WindowGroup {
            ReceiptView(
                dependency: components,
                service: ReceiptModelService(
                    dependency: components
                )
            )
            .preferredColorScheme(.light)
        }
    }
}

struct AppRootComponents: ReceiptModelDependency, ReceiptModelServiceDependency {
    @UserDefaultsWrapper(key: .mock, defaultValue: false) var mock: Bool
    
    var provider: DataProviding
    var mainScheduler: AnySchedulerOf<DispatchQueue>
    var backgroundScheduler: AnySchedulerOf<DispatchQueue>
    var deletionDate: PassthroughSubject<Date, Never>
    var reload: CurrentValueSubject<Void, Never>
    var selectedDate: CurrentValueSubject<Date, Never>
    
    init(
        provider: DataProviding = DataProvider(),
        mainScheduler: AnySchedulerOf<DispatchQueue> = .main,
        backgroundScheduler: AnySchedulerOf<DispatchQueue> = .main,
        deletionDate: PassthroughSubject<Date, Never> = .init(),
        reload: CurrentValueSubject<Void, Never> = .init(()),
        selectedDate: CurrentValueSubject<Date, Never> = .init(Date())
    ) {
        self.provider = provider
        self.mainScheduler = mainScheduler
        self.backgroundScheduler = backgroundScheduler
        self.deletionDate = deletionDate
        self.reload = reload
        self.selectedDate = selectedDate
        
        #if DEBUG
        if mock {
            self.provider = MockDataProvider()
        }
        #endif
    }
}
