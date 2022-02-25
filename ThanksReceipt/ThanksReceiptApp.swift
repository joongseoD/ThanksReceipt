//
//  ThanksReceiptApp.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import SwiftUI
import CombineSchedulers

@main
struct ThanksReceiptApp: App {
    var body: some Scene {
        WindowGroup {
            ReceiptView(
                dependency: AppRootComponents()
            )
            .preferredColorScheme(.light)
        }
    }
}

struct AppRootComponents: ReceiptModelDependency {
    @UserDefaultsWrapper(key: .mock, defaultValue: false) var mock: Bool
    
    var provider: DataProviding
    var pageSize: Int
    var mainScheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        provider: DataProviding = DataProvider(),
        pageSize: Int = 100,
        mainScheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.provider = provider
        self.pageSize = pageSize
        self.mainScheduler = mainScheduler
        
        #if DEBUG
        if mock {
            self.provider = MockDataProvider()
        }
        #endif
    }
}
