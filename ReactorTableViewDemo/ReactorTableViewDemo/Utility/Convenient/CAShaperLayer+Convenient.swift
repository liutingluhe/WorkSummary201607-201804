//
//  CAShaperLayer+Convenient.swift
//  ifanr
//
//  Created by luhe liu on 2018/7/17.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit

extension CAShapeLayer {
    public func setPointPath(with points: [CGPoint], isStroke: Bool = true) {
        let path = UIBezierPath()
        for (index, point) in points.enumerated() {
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        if isStroke {
            if let firstPoint = points.first {
                path.addLine(to: firstPoint)
            }
        }
        
        self.path = path.cgPath
    }
}
