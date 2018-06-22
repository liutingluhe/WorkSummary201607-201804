//
//  CustomPlaceholderView.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/6/21.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

class CustomPlaceholderView: RxBasicPlaceholderView {
    
    required init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.purple
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        print("CustomPlaceholderView dealloc")
    }
    
    override func updateSubviews() {
        self.backgroundColor = isNetworkError ? UIColor.brown : UIColor.purple
    }
}
