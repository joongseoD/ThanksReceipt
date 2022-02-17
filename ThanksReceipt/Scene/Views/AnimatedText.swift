//
//  AnimatedText.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/17.
//

import SwiftUI

struct AnimateText: View {
    @State private var maskingText: String = ""
    @State private var index = 0
    private var text: String
    private var kerning: CGFloat
    private var textList: [String] = []
    private var duration: Double = 0
    private var repeatAnimation: Bool = false
    
    init(_ text: String, kerning: CGFloat = 1.2) {
        self.text = text
        self.kerning = kerning
    }
    
    init(_ textList: [String], kerning: CGFloat = 1.2, duration: Double, repeatAnimation: Bool = false) {
        self.textList = textList
        self.text = textList.first ?? ""
        self.kerning = kerning
        self.duration = duration
        self.repeatAnimation = repeatAnimation
    }
    
    var body: some View {
        Text(maskingText)
            .kerning(kerning)
            .onChange(of: text) { newValue in
                animateMasking(newValue)
            }
            .onAppear { animateMasking(text) }
    }
    
    private func animateMasking(_ message: String) {
        maskingText = String(message.map { _ in "*" })
        
        DispatchQueue.global().async {
            message.enumerated().forEach { index, text in
                Thread.sleep(forTimeInterval: 0.02)
                DispatchQueue.main.async {
                    var chars = Array(maskingText)
                    guard chars.indices.contains(index) else { return }
                    chars[index] = text
                    maskingText = String(chars)
                }
                
                if message.count - 1 == index {
                    self.index += 1
                    
                    if repeatAnimation, textList.count == self.index {
                        self.index = 0
                    }
                    guard textList.indices.contains(self.index) else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        animateMasking(textList[self.index])
                    }
                }
            }
        }
    }
    
}

struct AnimatedText_Previews: PreviewProvider {
    static var previews: some View {
        AnimateText("")
    }
}
