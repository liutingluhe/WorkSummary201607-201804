//
//  UIViewController+RxConvenient.swift
//  ifanr
//
//  Created by luhe liu on 2018/7/13.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

// MARK: - sentMessage 会在调用方法前发送值
public extension Reactive where Base: UIViewController {
    public var viewDidLoadBefore: ControlEvent<Void> {
        let source = self.sentMessage(#selector(Base.viewDidLoad)).map { _ in }
        return ControlEvent(events: source)
    }
    
    public var viewWillAppearBefore: ControlEvent<Bool> {
        let source = self.sentMessage(#selector(Base.viewWillAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    public var viewDidAppearBefore: ControlEvent<Bool> {
        let source = self.sentMessage(#selector(Base.viewDidAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    public var viewWillDisappearBefore: ControlEvent<Bool> {
        let source = self.sentMessage(#selector(Base.viewWillDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    public var viewDidDisappearBefore: ControlEvent<Bool> {
        let source = self.sentMessage(#selector(Base.viewDidDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    public var viewWillLayoutSubviewsBefore: ControlEvent<Void> {
        let source = self.sentMessage(#selector(Base.viewWillLayoutSubviews)).map { _ in }
        return ControlEvent(events: source)
    }
    public var viewDidLayoutSubviewsBefore: ControlEvent<Void> {
        let source = self.sentMessage(#selector(Base.viewDidLayoutSubviews)).map { _ in }
        return ControlEvent(events: source)
    }
    
    public var willMoveToParentViewControllerBefore: ControlEvent<UIViewController?> {
        let source = self.sentMessage(#selector(Base.willMove)).map { $0.first as? UIViewController }
        return ControlEvent(events: source)
    }
    public var didMoveToParentViewControllerBefore: ControlEvent<UIViewController?> {
        let source = self.sentMessage(#selector(Base.didMove)).map { $0.first as? UIViewController }
        return ControlEvent(events: source)
    }
    
    public var didReceiveMemoryWarningBefore: ControlEvent<Void> {
        let source = self.sentMessage(#selector(Base.didReceiveMemoryWarning)).map { _ in }
        return ControlEvent(events: source)
    }
}
// MARK: - methodInvoked 会在调用方法后发送值
public extension Reactive where Base: UIViewController {
    public var viewDidLoadAfter: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
        return ControlEvent(events: source)
    }
    
    public var viewWillAppearAfter: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    public var viewDidAppearAfter: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewDidAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    public var viewWillDisappearAfter: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    public var viewDidDisappearAfter: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewDidDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    public var viewWillLayoutSubviewsAfter: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewWillLayoutSubviews)).map { _ in }
        return ControlEvent(events: source)
    }
    public var viewDidLayoutSubviewsAfter: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidLayoutSubviews)).map { _ in }
        return ControlEvent(events: source)
    }
    
    public var willMoveToParentViewControllerAfter: ControlEvent<UIViewController?> {
        let source = self.methodInvoked(#selector(Base.willMove)).map { $0.first as? UIViewController }
        return ControlEvent(events: source)
    }
    public var didMoveToParentViewControllerAfter: ControlEvent<UIViewController?> {
        let source = self.methodInvoked(#selector(Base.didMove)).map { $0.first as? UIViewController }
        return ControlEvent(events: source)
    }
    
    public var didReceiveMemoryWarningAfter: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.didReceiveMemoryWarning)).map { _ in }
        return ControlEvent(events: source)
    }
}
