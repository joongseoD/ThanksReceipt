//
//  ThanksReceiptApp.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import SwiftUI

@main
struct ThanksReceiptApp: App {
    var body: some Scene {
        WindowGroup {
            ReceiptView(
                dependency: ReceiptModelComponents(
                    provider: DataProvider(),
                    pageSize: 100
                )
            )
                .preferredColorScheme(.light)
        }
    }
}
