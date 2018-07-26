//
//  UITextField+RxConvenient.swift
//  ifanr
//
//  Created by luhe liu on 2018/6/26.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class RxTextFieldDelegateProxy: DelegateProxy, DelegateProxyType, UITextFieldDelegate {
    
    public var shouldReturn: (() -> Bool) = { true }
    public var shouldClear: (() -> Bool) = { true }
    public var shouldChangeCharacters: ((UITextField, NSRange, String) -> Bool) = { _, _, _ in true }
    public var didEndEdit: ((UITextField) -> Void) = { _ in }
    
    public override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        // swiftlint:disable:next force_cast
        let textField: UITextField = object as! UITextField
        return textField.createRxTextFieldDelegateProxy()
    }
    
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        if let textField = object as? UITextField {
            textField.delegate = delegate as? UITextFieldDelegate
        }
    }
    
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        if let textField = object as? UITextField {
            return textField.delegate
        }
        return nil
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self.shouldReturn()
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return self.shouldClear()
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return self.shouldChangeCharacters(textField, range, string)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        didEndEdit(textField)
    }
}

extension UITextField {
    
    public func createRxTextFieldDelegateProxy() -> RxTextFieldDelegateProxy {
        return RxTextFieldDelegateProxy(parentObject: self)
    }
}

extension Reactive where Base: UITextField {
    
    public var delegate: RxTextFieldDelegateProxy {
        return RxTextFieldDelegateProxy.proxyForObject(base)
    }
}
