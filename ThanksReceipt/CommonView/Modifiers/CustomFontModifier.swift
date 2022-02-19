//
//  CustomFontModifier.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/09.
//

import SwiftUI

struct CustomFontModifier: ViewModifier {
    
    enum Font: String {
        case DungGeunMo
    }
    
    let font: Self.Font
    let size: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(.custom(font.rawValue, size: size))
    }
}

extension View {
    func customFont(_ style: CustomFontModifier.Font, size: CGFloat) -> some View {
        self.modifier(CustomFontModifier(font: style, size: size))
    }
}
