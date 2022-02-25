//
//  AnyTransition+Extensions.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/25.
//

import SwiftUI

extension AnyTransition {
  static func stripes() -> AnyTransition {
    func stripesModifier(stripes: Int = 30, insertion: Bool = true, ratio: CGFloat) -> some ViewModifier {
      let shape = Stripes(stripes: stripes, insertion: insertion, ratio: ratio)
      return ShapeClipModifier(shape: shape)
    }
      return AnyTransition.asymmetric(
        insertion: AnyTransition.modifier(
            active: stripesModifier(ratio: 0),
            identity: stripesModifier(ratio: 1)
        ),
        removal: AnyTransition.modifier(
            active: stripesModifier(insertion: false, ratio: 0),
            identity: stripesModifier(insertion: false, ratio: 1)
        )
      )
  }
}
