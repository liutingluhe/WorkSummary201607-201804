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

class CollectionListViewController: UIViewController, View {
    
    var collectionView: CustomCollectionView!
    var disposeBag = DisposeBag()
    
    init(reactor: CollectionListViewReactor) {
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
        collectionView = CustomCollectionView(frame: self.view.bounds)
        collectionView.register(TestCollectionViewCell.self, forCellWithReuseIdentifier: "TestCollectionViewCell")
        self.view.addSubview(collectionView)
        self.view.backgroundColor = UIColor.white
    }
    
    func bind(reactor: CollectionListViewReactor) {
        
        reactor.collectionReactor.dataSource.configureCell = { dataSource, collectionView, indexPath, element in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestCollectionViewCell", for: indexPath) as! TestCollectionViewCell
            cell.reactor = element as? TestCollectionViewCellReactor
            return cell
        }
        reactor.collectionReactor.dataSource.supplementaryViewFactory = { _, _, _, _ in
            return UICollectionReusableView()
        }
        
        collectionView.reactor = reactor.collectionReactor
        
        reactor.state.asObservable()
            .filter({ $0.isRefresh })
            .map({ _ in BasicCollectionViewReactor.Action.loadFirstPage })
            .bind(to: reactor.collectionReactor.action)
            .disposed(by: disposeBag)
    }
}
