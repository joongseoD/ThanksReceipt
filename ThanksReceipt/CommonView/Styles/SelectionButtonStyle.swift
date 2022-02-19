//
//  ListSelectionStyle.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/14.
//

import SwiftUI

struct SelectionButtonStyle: ButtonStyle {
    var selectionColor: Color = .clear
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? selectionColor : Color.clear)
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
    }
}
