//
//  Image+Extensions.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/19.
//

import SwiftUI

extension Image {
    enum Symbol: String {
        case back = "arrow.left"
        case print = "printer"
        case write = "pencil"
        case selectDown = "chevron.compact.down"
        case delete = "trash"
        case check = "checkmark"
    }

    init(symbol: Symbol) {
        self.init(systemName: symbol.rawValue)
    }
}
