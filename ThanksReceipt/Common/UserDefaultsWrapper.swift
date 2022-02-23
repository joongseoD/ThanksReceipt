//
//  UserDefaultsWrapper.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/23.
//

import Foundation

@propertyWrapper
struct UserDefaultsWrapper<Value> {
    let key: String
    private let storage = UserDefaults.standard
    
    var wrappedValue: Value? {
        get {
            return storage.object(forKey: key) as? Value
        }
        set {
            if let newValue = newValue {
                storage.set(newValue, forKey: key)
            } else {
                storage.removeObject(forKey: key)
            }
        }
    }
}

