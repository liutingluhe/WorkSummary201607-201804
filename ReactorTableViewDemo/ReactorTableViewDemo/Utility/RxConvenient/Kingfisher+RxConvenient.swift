//
//  Kingfisher+RxConvenient.swift
//  ifanr
//
//  Created by luhe liu on 2018/6/26.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit
import Kingfisher
import RxCocoa
import RxSwift

public struct KingfisherImageResponse {
    public var image: UIImage?
    public var cacheType: CacheType = .none
    public var url: URL?
}

public struct KingfisherResponse {
    public var receivedSize: Int64 = 0
    public var expectedSize: Int64 = 0
    public var response: KingfisherImageResponse?
}

extension KingfisherManager: ReactiveCompatible {  }
extension Kingfisher: ReactiveCompatible {  }
extension RetrieveImageDiskTask: Cancellable { }
extension RetrieveImageDownloadTask: Cancellable { }

extension Reactive where Base: KingfisherManager {
    
    public func getImage(with urlStr: String, options: KingfisherOptionsInfo? = nil) -> Observable<Result<Image>> {
        
        return retrieveImage(forKey: urlStr, options: options).flatMapLatest({ (imageResult) -> Observable<Result<Image>> in
            if let image = imageResult.image {
                return .just(.success(image))
            } else if let url = URL(string: urlStr) {
                return self.downloadImage(with: url, options: options).flatMapLatest({ (downloadResult) -> Observable<Result<Image>> in
                    if let image = downloadResult.value?.image {
                        return .just(.success(image))
                    } else if let error = downloadResult.error {
                        return .just(.failure(error))
                    }
                    return .empty()
                })
            }
            return .empty()
        })
    }
    
    public func retrieveImage(forKey key: String, options: KingfisherOptionsInfo? = nil) -> Observable<KingfisherImageResponse> {
        return Observable.create { [weak kf = self.base] observer in
            guard let strongKf = kf else {
                return Disposables.create()
            }
            let imageTask = strongKf.cache.retrieveImage(forKey: key, options: options, completionHandler: { (image, cacheType) in
                let nextValue = KingfisherImageResponse(image: image, cacheType: cacheType, url: nil)
                observer.on(.next(nextValue))
                observer.on(.completed)
            })
            guard let task = imageTask else {
                return Disposables.create()
            }
            return Disposables.create(with: task.cancel)
        }
    }
    
    public func downloadImage(with url: URL, options: KingfisherOptionsInfo? = nil) -> Observable<Result<KingfisherImageResponse>> {
        return Observable.create { [weak kf = self.base] observer in
            guard let strongKf = kf else {
                return Disposables.create()
            }
            let imageTask = strongKf.downloader.downloadImage(with: url, options: options, progressBlock: nil, completionHandler: { (image, error, _, _) in
                if let error = error {
                    observer.on(.next(.failure(error)))
                } else {
                    let nextValue = KingfisherImageResponse(image: image, cacheType: .none, url: url)
                    observer.on(.next(.success(nextValue)))
                }
                observer.on(.completed)
            })
            guard let task = imageTask else {
                return Disposables.create()
            }
            return Disposables.create(with: task.cancel)
        }
    }
    
    public func getCacheSize() -> Observable<UInt> {
        return Observable.create { [weak kf = self.base] observer in
            guard let strongKf = kf else {
                return Disposables.create()
            }
            let task = CancellableWrapper()
            strongKf.cache.calculateDiskCacheSize(completion: { (totalCachedSize) in
                observer.on(.next(totalCachedSize))
                observer.on(.completed)
                
            })
            return Disposables.create(with: task.cancel)
        }
    }
    
    public func clearDiskCacheSize() -> Observable<Bool> {
        return Observable.create { [weak kf = self.base] observer in
            guard let strongKf = kf else {
                return Disposables.create()
            }
            let task = CancellableWrapper()
            strongKf.cache.clearDiskCache(completion: {
                observer.on(.next(true))
                observer.on(.completed)
            })
            return Disposables.create(with: task.cancel)
        }
    }
}

extension Reactive where Base: Kingfisher<UIImageView> {
    
    public func setImage(with resource: Resource?, placeholder: Image? = nil, options: KingfisherOptionsInfo? = nil) -> Observable<KingfisherResponse> {
        return Observable.create { observer in
            let task = self.base.setImage(with: resource, placeholder: placeholder, options: options, progressBlock: { (receivedSize, expectedSize) in
                let nextValue = KingfisherResponse(receivedSize: receivedSize, expectedSize: expectedSize, response: nil)
                observer.on(.next(nextValue))
            }, completionHandler: { (image, _, cacheType, url) in
                let response = KingfisherImageResponse(image: image, cacheType: cacheType, url: url)
                let nextValue = KingfisherResponse(receivedSize: 0, expectedSize: 0, response: response)
                observer.on(.next(nextValue))
                observer.on(.completed)
            })
            return Disposables.create(with: task.cancel)
        }
    }
}
