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
    let flexible: Bool
    
    func body(content: Content) -> some View {
        content
            .font(.custom(font.rawValue, size: adjustedSize))
    }
    
    private var adjustedSize: CGFloat {
        guard flexible else { return size }
        guard Constants.ratio < 1 else { return size }
        return min(Constants.ratio, 0.7) * size
    }
}

extension View {
    func customFont(_ style: CustomFontModifier.Font, size: CGFloat, flexible: Bool = true) -> some View {
        self.modifier(CustomFontModifier(font: style, size: size, flexible: flexible))
    }
}
