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
    
    required init(frame: CGRect, refreshView: UIScrollView?) {
        super.init(frame: frame, refreshView: refreshView)
        let logoLoadingView = LogoLoadingView(style: LogoLoadingStyle(style: .black))
        logoLoadingView.center = CGPoint(x: self.frame.size.width * 0.5, y: self.frame.size.height * 0.5)
        logoLoadingView.loadingHeight = self.frame.size.height
        loadingView = logoLoadingView
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        print("CustomHeaderRefreshView dealloc")
    }
}
