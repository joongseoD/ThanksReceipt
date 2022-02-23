//
//  ImageManager.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/22.
//

import UIKit

protocol ImageManagerProtocol: AnyObject {
    func save(image: UIImage) async throws -> UIImage
}

final class ImageManager: NSObject, ImageManagerProtocol, UIImagePickerControllerDelegate {
    private var continuation: CheckedContinuation<UIImage, Error>?
    
    func save(image: UIImage) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.continuation = continuation
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        guard let error = error else {
            continuation?.resume(returning: image)
            continuation = nil
            return
        }
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
