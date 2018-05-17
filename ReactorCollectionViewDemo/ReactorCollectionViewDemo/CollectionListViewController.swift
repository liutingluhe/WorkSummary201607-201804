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
    
    var collectionView: BasicCollectionView!
    var disposeBag = DisposeBag()
    let cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    
    init(reactor: CollectionListViewReactor) {
        super.init(nibName: nil, bundle: nil)
        setupSubviews()
        self.reactor = reactor
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        collectionView = BasicCollectionView(frame: self.view.bounds)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        self.view.addSubview(collectionView)
    }
    
    func bind(reactor: CollectionListViewReactor) {
        
        collectionView.rx
            .setDelegate(collectionView)
            .disposed(by: disposeBag)
        
        reactor.collectionReactor.dataSource.configureCell = { dataSource, collectionView, indexPath, element in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
            cell.backgroundColor = element.didSelected ? UIColor.blue : UIColor.red
            return cell
        }
        reactor.collectionReactor.dataSource.supplementaryViewFactory = { _, _, _, _ in
            return UICollectionReusableView()
        }
        
        collectionView.layoutSource.configureSizeForCell = { reactor.collectionReactor.getCellSize(indexPath: $0) }
        collectionView.reactor = reactor.collectionReactor
        
        reactor.state.filter({ $0.isRefresh })
            .map({ _ in BasicCollectionViewReactor.Action.loadFirstPage })
            .bind(to: reactor.collectionReactor.action)
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .map({ BasicCollectionViewReactor.Action.deleteIndexs([$0]) })
            .bind(to: reactor.collectionReactor.action)
            .disposed(by: disposeBag)
    }
}
