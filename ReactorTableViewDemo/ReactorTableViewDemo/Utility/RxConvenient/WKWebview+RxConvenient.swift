//
//  WKWebview+RxConvenient.swift
//  ifanr
//
//  Created by luhe liu on 2018/6/26.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit
import WebKit
import RxCocoa
import RxSwift

public class RxWKWebViewNavigationDelegateProxy: DelegateProxy, DelegateProxyType, WKNavigationDelegate {
    
    public var checkRequestIsAllow: ((String?) -> WKNavigationActionPolicy) = { _ in .allow }
    public var checkResponseIsAllow: ((String?) -> WKNavigationResponsePolicy) = { _ in .allow }
    public var didReceiveChallenge: ((URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?)) = { _ in (.performDefaultHandling, nil) }
    
    public override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        // swiftlint:disable:next force_cast
        let pickerView: WKWebView = object as! WKWebView
        return pickerView.createRxNavigationDelegateProxy()
    }
    
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        if let webView = object as? WKWebView {
            webView.navigationDelegate = delegate as? WKNavigationDelegate
        }
    }
    
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        if let webView = object as? WKWebView {
            return webView.navigationDelegate
        }
        return nil
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        let isAllow = checkResponseIsAllow(navigationResponse.response.url?.absoluteString)
        decisionHandler(isAllow)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let isAllow = checkRequestIsAllow(navigationAction.request.url?.absoluteString)
        decisionHandler(isAllow)
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        let (disposition, credential) = didReceiveChallenge(challenge)
        completionHandler(disposition, credential)
    }
}

extension WKWebView {
    
    public func createRxNavigationDelegateProxy() -> RxWKWebViewNavigationDelegateProxy {
        return RxWKWebViewNavigationDelegateProxy(parentObject: self)
    }
}

extension Reactive where Base: WKWebView {
    
    public var delegate: RxWKWebViewNavigationDelegateProxy {
        return RxWKWebViewNavigationDelegateProxy.proxyForObject(base)
    }
    
    // MARK: 方法监听
    public var didStartProvisionalNavigation: Observable<Void> {
        return delegate
            .methodInvoked(#selector(WKNavigationDelegate.webView(_:didStartProvisionalNavigation:)))
            .map {_ in}
    }
    
    public var didFinish: Observable<Void> {
        return delegate
            .methodInvoked(#selector(WKNavigationDelegate.webView(_:didFinish:)))
            .map {_ in}
    }
    
    public var didFail: Observable<Void> {
        return delegate
            .methodInvoked(#selector(WKNavigationDelegate.webView(_:didFail:withError:)))
            .map {_ in}
    }
    
    public func evaluateJavaScript(_ javaScriptString: String) -> Observable<Any> {
        
        return Observable.create { [weak base = self.base] observer in
            guard let strongBase = base else {
                return Disposables.create()
            }
            let task = CancellableWrapper()
            strongBase.evaluateJavaScript(javaScriptString) { (content, _) in
                if let content = content {
                    observer.on(.next(content))
                }
                observer.on(.completed)
            }
            return Disposables.create(with: task.cancel)
        }
    }
    
    // MARK: 属性监听
    public var title: Observable<String?> {
        return self.observeWeakly(String.self, "title")
    }
    
    public var loading: Observable<Bool> {
        return self.observeWeakly(Bool.self, "loading").map { $0 ?? false }
    }
    
    public var estimatedProgress: Observable<Double> {
        return self.observeWeakly(Double.self, "estimatedProgress").map { $0 ?? 0.0 }
    }
    
    public var url: Observable<URL?> {
        return self.observeWeakly(URL.self, "url")
    }
    
    public var canGoBack: Observable<Bool> {
        return self.observeWeakly(Bool.self, "canGoBack").map { $0 ?? false }
    }
    
    public var canGoForward: Observable<Bool> {
        return self.observeWeakly(Bool.self, "canGoForward").map { $0 ?? false }
    }
}
