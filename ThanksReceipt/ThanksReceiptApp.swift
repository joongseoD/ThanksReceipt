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
    var provider: DataProviding = DataProvider()
    var pageSize: Int = 100
    var mainScheduler: AnySchedulerOf<DispatchQueue> = .main
}
