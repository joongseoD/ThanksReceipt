//
//  UserDefaultsWrapper.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/23.
//

import Foundation

@propertyWrapper
struct UserDefaultsWrapper<Value> {
    private let storage = UserDefaults.standard
    let key: UserDefaultsKey
    var defaultValue: Value
    
    var wrappedValue: Value {
        get {
            return storage.object(forKey: key.rawValue) as? Value ?? defaultValue
        }
        set {
            storage.set(newValue, forKey: key.rawValue)
        }
    }
}

enum UserDefaultsKey: String {
    case mock
}
