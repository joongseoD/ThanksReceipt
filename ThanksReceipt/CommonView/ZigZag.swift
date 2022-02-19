//
//  ZigZag.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/11.
//

import SwiftUI

struct ZigZag: Shape {
    func path(in rect: CGRect) -> Path {
        let minX = Int(rect.minX)
        let maxX = Int(rect.maxX)
        let range = (minX...maxX)
        
        return Path() { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 5))
            range.forEach { x in
                guard x % 5 == 0 else { return }
                let y = x % 10 == 0 ? 5 : 0
                path.addLine(to: CGPoint(x: x, y: y))
            }
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            range.forEach { xx in
                let x = maxX - xx
                guard x % 5 == 0 else { return }
                let y = x % 10 == 0 ? Int(rect.maxY) : Int(rect.maxY) - 5
                path.addLine(to: CGPoint(x: x, y: y))
            }
            path.closeSubpath()
        }
    }
}

struct ZigZag_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("A")
            Text("B")
        }
        .frame(width: 200, height: 200)
        .background(Color.red)
        .clipShape(ZigZag())
    }
}
