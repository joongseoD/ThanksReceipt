//
//  ColorPallete.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/16.
//

import SwiftUI

struct ColorPallete: View {
    @Binding var selection: Color
    var colorList: [Color]
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal) {
                HStack {
                    ColorPicker("", selection: $selection)
                        .frame(width: 30, height: 30)
                        .padding(.trailing, 2)
                    
                    ForEach(colorList, id: \.self) { color in
                        Button(action: { selection = color }) {
                            color
                                .clipShape(Circle())
                                .frame(width: 30, height: 30)
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0.5, y: 0.5)
                                .padding(.vertical, 5)
                            
                        }
                        .buttonStyle(SelectionButtonStyle())
                    }
                }
            }
            .frame(width: proxy.size.width)
        }
        .frame(height: 35)
        .padding(.horizontal, 15)
        .padding(.vertical, 15)
        .background(Color.background)
    }
}

struct ColorPallete_Previews: PreviewProvider {
    static var previews: some View {
        ColorPallete(selection: .constant(.white), colorList: [])
    }
}
