//
//  UIView+Extensions.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/14.
//

import SwiftUI

extension View {
    func takeScreenshot(size: CGSize) -> UIImage? {
        let viewController = UIHostingController(rootView: self)
        let ratio = viewController.view.intrinsicContentSize.height / size.width
        let backgroundWidth = size.width * ratio
        let backgroundSize = CGSize(width: backgroundWidth, height: backgroundWidth)
        
        guard let view = viewController.view else { return nil }
        
        view.backgroundColor = .clear
        view.bounds = CGRect(origin: .zero, size: backgroundSize)

        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, Constants.snapshotScale)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        return image
    }
}
