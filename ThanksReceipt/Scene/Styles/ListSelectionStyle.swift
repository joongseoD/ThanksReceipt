//
//  ListSelectionStyle.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/14.
//

import SwiftUI

struct ListSelectionStyle: ButtonStyle {
    var selectionColor: Color = .gray
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? selectionColor : Color.clear)
    }
}
