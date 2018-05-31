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

class CustomHeaderRefreshView: BasicHeaderRefreshView {
    
    required init(frame: CGRect, refreshView: UIScrollView?) {
        super.init(frame: frame, refreshView: refreshView)
        loadingClass = CustomLoadingView.self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        print("CustomHeaderRefreshView dealloc")
    }
}
