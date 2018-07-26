//
//  Photos+RxConvenient.swift
//  ifanr
//
//  Created by luhe liu on 2018/6/26.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Photos

extension Reactive where Base: PHImageManager {
    
    public func requestImage(for asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?) -> Observable<UIImage?> {
        return Observable.create { [weak base = self.base] observer in
            guard let strongBase = base else {
                return Disposables.create()
            }
            let taskID = strongBase.requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options) { (image, info) in
                observer.on(.next(image))
                // 此处会调用多次，第一次是低清图，第二次才是我们需要的高清图
                if let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool, !isDegraded {
                    observer.on(.completed)
                }
            }
            return Disposables.create {
                strongBase.cancelImageRequest(taskID)
            }
        }
    }
}

extension Reactive where Base: PHPhotoLibrary {
    
    public func requestAuthorization() -> Observable<PHAuthorizationStatus> {
        return Observable.create { observer in
            let task = CancellableWrapper()
            PHPhotoLibrary.requestAuthorization() { (authorizationStatus) in
                observer.on(.next(authorizationStatus))
                observer.on(.completed)
            }
            return Disposables.create(with: task.cancel)
        }
    }
}

extension Reactive where Base: PHAsset {
   
    public func requestImage(resizeMode: PHImageRequestOptionsResizeMode = .fast, imageSize: CGSize = .zero, contentMode: PHImageContentMode = .aspectFill, isMaximumSize: Bool = false) -> Observable<UIImage?> {
        let option = PHImageRequestOptions()
        option.resizeMode = resizeMode
        var size: CGSize = .zero
        if isMaximumSize {
            size = PHImageManagerMaximumSize
        } else {
            let scale: CGFloat = UIScreen.main.scale
            size = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        }
        
        return PHImageManager.default().rx.requestImage(for: base, targetSize: size, contentMode: contentMode, options: option)
    }
}
