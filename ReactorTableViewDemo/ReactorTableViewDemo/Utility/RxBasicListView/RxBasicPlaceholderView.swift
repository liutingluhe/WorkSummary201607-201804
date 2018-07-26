//
//  RxBasicPlaceholderView.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/6/21.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit

open class RxBasicPlaceholderView: UIView {
    
    open var isFirstRefreshHidden: Bool = true
    open var isNetworkError: Bool = false {
        didSet {
            updateSubviews()
        }
    }

    /// 初始化方法
    public required override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    /// 初始化方法
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    open func setupSubviews() {
    }
    
    open func updateSubviews() {
    }

}
