//
//  UIScrollView+Convenient.swift
//  ifanr
//
//  Created by luhe liu on 2018/7/26.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    func removeAdjustmentBehavior() {
        if #available(iOS 11.0, *) {
            self.contentInsetAdjustmentBehavior = .never
        } else {
            self.responderController?.automaticallyAdjustsScrollViewInsets = false
        }
    }
}
