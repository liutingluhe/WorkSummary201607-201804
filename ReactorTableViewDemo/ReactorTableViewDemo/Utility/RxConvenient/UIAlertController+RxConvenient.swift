//
//  UIAlertController+RxConvenient.swift
//  ifanr
//
//  Created by luhe liu on 2018/7/13.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public protocol AlertActionType {
    var title: String? { get }
    var style: UIAlertActionStyle { get }
}

public extension AlertActionType {
    public var style: UIAlertActionStyle {
        return .default
    }
}

public protocol AlertType {
    
    associatedtype ActionType: AlertActionType
    
    var title: String? { get }
    var message: String? { get }
    var style: UIAlertControllerStyle { get }
    var actions: [ActionType] { get }
}

extension AlertType {
    public var title: String? { return "" }
    public var message: String? { return "" }
    public var style: UIAlertControllerStyle { return .alert }
}

public enum AlertResponse<T: AlertActionType> {
    case willPresent
    case didPresent
    case action(T)
}

extension Reactive where Base: UIViewController {
    
    public func showAlert<T: AlertType>(type: T, animated: Bool = true, dimissCompletion: (() -> Void)? = nil) -> Observable<AlertResponse<T.ActionType>> {
        return Observable.create { [weak base = self.base] observer in
            guard let strongBase = base else {
                return Disposables.create()
            }
            let alert = UIAlertController(title: type.title, message: type.message, preferredStyle: type.style)
            for action in type.actions {
                let alertAction = UIAlertAction(title: action.title, style: action.style) { _ in
                    observer.on(.next(.action(action)))
                    observer.on(.completed)
                }
                alert.addAction(alertAction)
            }
            observer.on(.next(.willPresent))
            strongBase.present(alert, animated: animated, completion: {
                observer.on(.next(.didPresent))
            })
            return Disposables.create {
                alert.dismiss(animated: animated, completion: dimissCompletion)
            }
        }
    }
}

extension Reactive where Base: UIView {
    
    public func showAlert<T: AlertType>(type: T, animated: Bool = true, dimissCompletion: (() -> Void)? = nil) -> Observable<AlertResponse<T.ActionType>> {
        return Observable.create { [weak base = self.base] observer in
            guard let strongBase = base, let responderController = strongBase.responderController else {
                return Disposables.create()
            }
            let alert = UIAlertController(title: type.title, message: type.message, preferredStyle: type.style)
            for action in type.actions {
                let alertAction = UIAlertAction(title: action.title, style: action.style) { _ in
                    observer.on(.next(.action(action)))
                    observer.on(.completed)
                }
                alert.addAction(alertAction)
            }
            observer.on(.next(.willPresent))
            responderController.present(alert, animated: animated, completion: {
                observer.on(.next(.didPresent))
            })
            return Disposables.create {
                alert.dismiss(animated: animated, completion: dimissCompletion)
            }
        }
    }
}
