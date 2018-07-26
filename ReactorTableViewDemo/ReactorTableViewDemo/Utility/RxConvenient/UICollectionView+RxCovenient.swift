//
//  UICollectionView+RxCovenient.swift
//  ifanr
//
//  Created by luhe liu on 2018/7/4.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class RxCollectionDelegateProxy: DelegateProxy, DelegateProxyType, UICollectionViewDelegate {
    
    public var shouldSelectItemAt: (IndexPath) -> Bool = { _ in true }
    public var shouldHighlightItemAt: (IndexPath) -> Bool = { _ in true }
    public var shouldDeselectItemAt: (IndexPath) -> Bool = { _ in true }
    public var shouldShowMenuForItemAt: (IndexPath) -> Bool = { _ in true }
    public var canFocusItemAt: (IndexPath) -> Bool = { _ in true }
    public var canPerformAction: (Selector, IndexPath, Any?) -> Bool = { _, _, _ in true }
    
    public override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        // swiftlint:disable:next force_cast
        let pickerView: UICollectionView = object as! UICollectionView
        return pickerView.createRxCollectionDelegateProxy()
    }
    
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        if let webView = object as? UICollectionView {
            webView.delegate = delegate as? UICollectionViewDelegate
        }
    }
    
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        if let webView = object as? UICollectionView {
            return webView.delegate
        }
        return nil
    }

    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return shouldHighlightItemAt(indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return shouldSelectItemAt(indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return shouldDeselectItemAt(indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return shouldShowMenuForItemAt(indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return canPerformAction(action, indexPath, sender)
    }

}

extension UICollectionView {
    
    public func createRxCollectionDelegateProxy() -> RxCollectionDelegateProxy {
        return RxCollectionDelegateProxy(parentObject: self)
    }
}

extension Reactive where Base: UICollectionView {
    
    public var delegate: RxCollectionDelegateProxy {
        return RxCollectionDelegateProxy.proxyForObject(base)
    }
}
