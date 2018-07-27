//
//  CollectionListViewController.swift
//  RxTodo
//
//  Created by luhe liu on 2018/5/16.
//  Copyright © 2018年 Suyeol Jeon. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

class TableListViewController: UIViewController, View {
    
    var tableView: CustomTableView!
    var disposeBag = DisposeBag()
    
    init(reactor: TableListViewReactor) {
        super.init(nibName: nil, bundle: nil)
        setupSubviews()
        self.reactor = reactor
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("CollectionListViewController dealloc")
    }
    
    func setupSubviews() {
        tableView = CustomTableView(frame: self.view.bounds, style: .grouped)
        tableView.contentInset.top = 64
        tableView.separatorStyle = .none
        self.view.addSubview(tableView)
        self.view.backgroundColor = UIColor.white
    }
    
    func bind(reactor: TableListViewReactor) {
        reactor.tableReactor.dataSource.configureCell = { dataSource, tableView, indexPath, element in
            let cell = tableView.dequeueReusableCell(TestTableViewCell.self)
            cell.reactor = element as? TestTableViewCellReactor
            cell.selectionStyle = .none
            return cell
        }
        
        tableView.basicReactor = reactor.tableReactor
        
        reactor.state.asObservable()
            .filter({ $0.isRefresh })
            .map({ _ in RxBasicTableViewReactor.Action.loadFirstPage })
            .bind(to: reactor.tableReactor.action)
            .disposed(by: disposeBag)
        
    }
}
