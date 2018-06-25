//
//  CustomHeaderRefreshView.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/5/30.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

class CustomHeaderRefreshView: RxBasicHeaderRefreshView {
    
    lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(refreshEnding))
        displayLink.add(to: RunLoop.main, forMode: .commonModes)
        displayLink.isPaused = true
        return displayLink
    }()
    
    required init(frame: CGRect, scrollView: UIScrollView?) {
        super.init(frame: frame, scrollView: scrollView)
        let logoLoadingView = LogoLoadingView(style: LogoLoadingStyle(style: .black))
        logoLoadingView.center = CGPoint(x: self.frame.size.width * 0.5, y: self.frame.size.height * 0.5)
        logoLoadingView.loadingHeight = self.frame.size.height
        loadingView = logoLoadingView
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        displayLink.isPaused = true
        print("CustomHeaderRefreshView dealloc")
    }
    
    override func willEndRefresh() {
        super.willEndRefresh()
        displayLink.isPaused = false
    }
    
    override func didEndRefresh() {
        super.didEndRefresh()
        displayLink.isPaused = true
    }
    
    @objc func refreshEnding() {
        guard let scrollView = self.scrollView else { return }
        if let delegate = scrollView.delegate, let didScroll = delegate.scrollViewDidScroll {
            didScroll(scrollView)
        }
    }
}
