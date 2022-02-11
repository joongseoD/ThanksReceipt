//
//  Color+Extensions.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/11.
//

import SwiftUI

extension Color {
    static let background = Color(hex: "#F4F3EE")
    static let text = Color.black
    
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double((rgb >> 0) & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
        
    }
}
