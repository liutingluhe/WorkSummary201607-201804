//
//  WaterCollectionViewCell.swift
//  WaterFlowLayoutDemo
//
//  Created by luhe liu on 2018/3/31.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit

class WaterCollectionViewCell: UICollectionViewCell {
    
    static let titleAttribute: [String: Any] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byCharWrapping
        let attributes: [String : Any] = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 14),
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        return attributes
    }()

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = UIColor.black
        titleLabel.numberOfLines = 0
        self.backgroundColor = UIColor.red
    }

}
