//
//  TestTableViewCell.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/5/18.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(_ classType: T.Type, style: UITableViewCellStyle = .default) -> T {
        let Identifier = classType.className
        if let cell = self.dequeueReusableCell(withIdentifier: Identifier) as? T {
            return cell
        }
        return T.init(style: style, reuseIdentifier: Identifier)
    }
}

class TestTableViewCell: UITableViewCell, View {
    
    struct Constraint {
        static let cellSize = CGSize(width: UIScreen.main.bounds.size.width, height: 50)
        static let padding: CGFloat = 10
    }
    
    fileprivate var titleLabel: UILabel!
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupTitleLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTitleLabel()
    }
    
    deinit {
        print("TestTableViewCell dealloc")
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
    
    func bind(reactor: TestTableViewCellReactor) {
        titleLabel.text = reactor.currentState.model.title
        backgroundColor = reactor.didSelected ? UIColor.blue : UIColor.green
        
        reactor.state.asObservable()
            .filter({ $0.isPush })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                let listVCReactor = TableListViewReactor()
                let listVC = TableListViewController(reactor: listVCReactor)
                self?.responderController?.navigationController?.pushViewController(listVC, animated: true)
            }).disposed(by: disposeBag)
    }
}
