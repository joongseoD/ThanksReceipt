//
//  ColorPallete.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/16.
//

import SwiftUI

struct ColorPalette: View {
    @State private var pickerColor: Color = .white
    @Binding var selection: Palette
    var colorList: [Palette]
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ColorPicker("", selection: $pickerColor)
                        .frame(width: 30, height: 30)
                        .padding(.trailing, 2)
                    
                    ForEach(colorList, id: \.id) { color in
                        Button(action: { selection = color }) {
                            ColorBuilderView(palette: color)
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
        .onChange(of: pickerColor) { newValue in
            selection = .single(newValue)
        }
    }
}

struct ColorBuilderView: View {
    var palette: Palette
    
    var body: some View {
        switch palette {
        case .single(let color):
            return AnyView(color)
        case .gradient(let colors):
            return AnyView(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom))
        }
    }
}

struct ColorPalette_Previews: PreviewProvider {
    static var previews: some View {
        ColorPalette(selection: .constant(.single(.white)), colorList: [])
    }
}
