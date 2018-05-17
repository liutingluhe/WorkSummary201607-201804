//
//  BasicCollectionView.swift
//  RxTodo
//
//  Created by luhe liu on 2018/5/16.
//  Copyright © 2018年 Suyeol Jeon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import ReactorKit

class BasicCollectionView: UICollectionView, View, UICollectionViewDelegateFlowLayout {
    
    var disposeBag = DisposeBag()
    var scrollDirection: UICollectionViewScrollDirection = .vertical
    var reloadDebounceTime: TimeInterval = 0.3
    var releaseHeight: CGFloat = 100
    var loadNextPageInset: CGFloat = 200
    var canRefresh: Bool = true
    var layoutSource = CollectionViewLayoutSource()
    
    init(frame: CGRect, flow: UICollectionViewFlowLayout = UICollectionViewFlowLayout()) {
        self.scrollDirection = flow.scrollDirection
        super.init(frame: frame, collectionViewLayout: flow)
        configureCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureCollectionView()
    }
    
    func configureCollectionView() {
        
        self.alwaysBounceVertical = self.scrollDirection == .vertical
        self.alwaysBounceHorizontal = self.scrollDirection == .horizontal
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        self.backgroundColor = UIColor.clear
    }

    // CollectionView 动作绑定
    func bind(reactor: BasicCollectionViewReactor) {
        
        // 加载更多
        self.rx.didScroll
            .filter { [weak self] _ -> Bool in
                guard let strongSelf = self else { return false }
                var result: Bool = false
                let contentSize = strongSelf.contentSize
                switch strongSelf.scrollDirection {
                case .vertical:
                    guard contentSize.height > 0 else { return false }
                    result = strongSelf.contentOffset.y > contentSize.height - strongSelf.contentInset.top - (strongSelf.frame.size.height + strongSelf.loadNextPageInset)
                case .horizontal:
                    guard contentSize.width > 0 else { return false }
                    result = strongSelf.contentOffset.x > contentSize.width - strongSelf.contentInset.left - (strongSelf.frame.size.width + strongSelf.loadNextPageInset)
                }
                return result
            }
            .map { _ in Reactor.Action.loadNextPage }
            .throttle(reloadDebounceTime, scheduler: MainScheduler.instance)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // 准备加载第一页
        self.rx.didEndDragging
            .filter { [weak self] _ in
                guard let strongSelf = self, strongSelf.scrollDirection == .vertical else { return false }
                guard strongSelf.canRefresh else { return false }
                return strongSelf.contentOffset.y < -strongSelf.releaseHeight - strongSelf.contentInset.top
            }
            .map { _ in Reactor.Action.loadFirstPage }
            .observeOn(MainScheduler.instance)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // 立即刷新数据
        let refresh = reactor.state.asObservable()
                .filter({ $0.isRefresh })
                .map { $0.sections }
                .observeOn(MainScheduler.instance)
        
        // 延后刷新数据
        let fetchData = reactor.state.asObservable()
                .filter({ $0.isFetchData })
                .map { $0.sections }
                .debounce(reloadDebounceTime, scheduler: MainScheduler.instance)
        
        Observable.merge([refresh, fetchData])
            .asDriver(onErrorJustReturn: [])
            .drive(self.rx.items(dataSource: reactor.dataSource))
            .disposed(by: self.disposeBag)
        
        if reactor.isAnimated {
            Observable.merge([refresh, fetchData])
                .map({ _ in true })
                .delay(0.1, scheduler: MainScheduler.instance)
                .asDriver(onErrorJustReturn: false)
                .drive(self.rx.reload)
                .disposed(by: self.disposeBag)
        }
    }
}

extension BasicCollectionView {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return layoutSource.sizeForCell.at(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return layoutSource.insetForSection.at(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return layoutSource.minLineSpacing.at(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return layoutSource.minInteritemSpacing.at(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return layoutSource.sizeForHeader.at(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return layoutSource.sizeForFooter.at(section)
    }
}
