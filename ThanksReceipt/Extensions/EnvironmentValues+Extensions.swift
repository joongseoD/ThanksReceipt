//
//  EnvironmentValues+Extensions.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/28.
//

import SwiftUI

private struct EnvironmentScaleKey: EnvironmentKey {
    static let defaultValue: CGFloat = 1.0
}

extension EnvironmentValues {
    var contentsScale: CGFloat {
        get { self[EnvironmentScaleKey.self] }
        set { self[EnvironmentScaleKey.self] = newValue }
    }
}
