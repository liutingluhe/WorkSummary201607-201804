//
//  TestCollectionViewCell.swift
//  CommonExtensionDemo
//
//  Created by luhe liu on 2018/3/25.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit

class TestCollectionViewCell: UICollectionViewCell {
    
    static let titleFont: UIFont = UIFont.boldFont(ofSize: 14, type: .SFProText)

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // MARK: 测试通用字体方法
        titleLabel.font = TestCollectionViewCell.titleFont
    }
}
