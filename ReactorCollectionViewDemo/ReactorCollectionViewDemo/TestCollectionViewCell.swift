//
//  TestCollectionViewCell.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/5/18.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

class TestCollectionViewCell: UICollectionViewCell, View {
    
    struct Constraint {
        static let cellSize = CGSize(width: UIScreen.main.bounds.size.width, height: 50)
        static let padding: CGFloat = 10
    }
    
    fileprivate var titleLabel: UILabel!
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTitleLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTitleLabel()
    }
    
    fileprivate func setupTitleLabel() {
        titleLabel = UILabel(frame: CGRect(origin: .zero, size: Constraint.cellSize))
        titleLabel.textColor = UIColor.red
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textAlignment = .left
        self.addSubview(titleLabel)
        
        titleLabel.frame.origin.x = Constraint.padding
        titleLabel.frame.size.width = Constraint.cellSize.width - Constraint.padding * 2
        titleLabel.frame.size.height = Constraint.cellSize.height - Constraint.padding * 2
        titleLabel.center.y = Constraint.cellSize.height * 0.5
    }
    
    func bind(reactor: TestCollectionViewCellReactor) {
        titleLabel.text = reactor.currentState.model.title
        backgroundColor = reactor.didSelected ? UIColor.blue : UIColor.green
    }
}
