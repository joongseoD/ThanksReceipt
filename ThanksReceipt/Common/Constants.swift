//
//  Constants.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/15.
//

import SwiftUI

struct Constants {
    static let headerText: String = "* Thanks Receipt *"
    static let footerText: String = "THANKS FOR GIVING ME A DAY!"
    static let paletteColors: [Palette] = [
        .single(.white),
        .single(.black),
        .single(.blue),
        .single(.green),
        .single(.yellow),
        .single(.orange),
        .single(.pink),
        .single(.red),
        .single(.purple),
        .gradient([Color(hex: "#1A1A40"), Color(hex: "#270082"), Color(hex: "#7A0BC0"), Color(hex: "#FA58B6")]),
        .gradient([Color(hex: "#FFD32D"), Color(hex: "#008E89"), Color(hex: "#085E7D"), Color(hex: "#084594")]),
        .gradient([Color(hex: "#C1F4C5"), Color(hex: "#FF7BA9")]),
        .gradient([.blue, .pink]),
        .gradient([.green, .blue]),
        .gradient([.purple, .pink]),
        .gradient([.yellow, .red]),
        .gradient([.pink, .orange]),
    ]
    
    static let screenSize: CGSize = UIScreen.main.bounds.size
    static var screenWidth: CGFloat { screenSize.width }
    static let snapshotQuality: CGFloat = 1.9
    static let standardWidth: CGFloat = 375.0
    static var ratio: CGFloat { screenWidth / standardWidth }
}

enum Palette: Identifiable, Equatable {
    case single(_: Color)
    case gradient(_: [Color])
    
    var id: UUID { UUID() }
}
