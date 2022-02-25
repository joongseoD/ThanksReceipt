//
//  Logger.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/23.
//

import Foundation
import Firebase
import FirebaseAnalytics

final class Logger {
    static let shared = Logger()
    
    private init() {
        FirebaseApp.configure()
    }
    
    func sendScreenLog(viewName: String) {
        send(
            name: AnalyticsEventScreenView,
            parameters: [
                AnalyticsEventScreenView : viewName,
                AnalyticsParameterScreenClass : viewName
            ]
        )
    }
    
    func send(name: String, parameters: [String : Any]?) {
        Analytics.logEvent(
            name,
            parameters: parameters
        )
        
        log("[Log] name: \(name), parameter: \(parameters as Any)")
    }
    
    private func log(_ description: String) {
        #if DEBUG
        print(description)
        #endif
    }
}
