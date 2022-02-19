//
//  Line.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/11.
//

import SwiftUI

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

struct LineStroke: View {
    var lineWidth: CGFloat = 1
    var height: CGFloat = 3
    
    var body: some View {
        Line()
            .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .miter, miterLimit: 0, dash: [5], dashPhase: 0))
            .frame(height: height)
    }
}

struct Line_Previews: PreviewProvider {
    static var previews: some View {
        LineStroke()
    }
}
