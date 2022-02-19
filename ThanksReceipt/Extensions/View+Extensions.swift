//
//  UIView+Extensions.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/14.
//

import SwiftUI

extension View {
    func takeScreenshot(size: CGSize) -> UIImage {
        let viewController = UIHostingController(rootView: self)
        let ratio = viewController.view.intrinsicContentSize.height / size.width
        let backgroundWidth = size.width * ratio
        let backgroundSize = CGSize(width: backgroundWidth, height: backgroundWidth)
        
        viewController.view.bounds = CGRect(origin: .zero,
                                            size: backgroundSize)
        let renderer = UIGraphicsImageRenderer(size: backgroundSize)
        let image = renderer.image { _ in
            viewController.view.drawHierarchy(in: viewController.view.bounds, afterScreenUpdates: true)
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        return image
    }
}
