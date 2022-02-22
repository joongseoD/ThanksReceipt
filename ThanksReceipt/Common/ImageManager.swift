//
//  ImageManager.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/22.
//

import UIKit

final class ImageManager: NSObject, ImageManagerProtocol, UIImagePickerControllerDelegate {
    
    var completion: ((Result<UIImage, Error>) -> Void)?
    
    func save(image: UIImage, completion: ((Result<UIImage, Error>) -> Void)?) {
        self.completion = completion
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        guard let error = error else {
            completion?(.success(image))
            return
        }

        completion?(.failure(error))
    }
}

protocol ImageManagerProtocol: AnyObject {
    var completion: ((Result<UIImage, Error>) -> Void)? { get }
    
    func save(image: UIImage, completion: ((Result<UIImage, Error>) -> Void)?)
}
