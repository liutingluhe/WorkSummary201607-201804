//
//  RxCollectionViewSectionedAnimatedReloadDataSource.swift
//  RxTodo
//
//  Created by luhe liu on 2018/5/17.
//  Copyright © 2018年 Suyeol Jeon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

/// 实现一个可以控制是否进行列表动画的数据源
open class RxCollectionViewSectionedAnimatedReloadDataSource<S: AnimatableSectionModelType>: CollectionViewSectionedDataSource<S>, RxCollectionViewDataSourceType {
    
    public typealias Element = [S]
    
    public var animationConfiguration = AnimationConfiguration()
    private var dataSet = false
    public let disposeBag = DisposeBag()
    public let partialUpdateEvent = PublishSubject<(UICollectionView, Event<Element>)>()
    public var isAutoUpdate: Bool = false
    public var isAnimated: Bool = false
    public var throttleTime: TimeInterval = 0.5
    private var throttledEventDidSet: Bool = false
    
    public override init() {
        super.init()
    }
    
    open func collectionView(_ collectionView: UICollectionView, throttledObservedEvent event: Event<Element>) {
        UIBindingObserver(UIElement: self) { dataSource, newSections in
            let oldSections = dataSource.sectionModels
            do {
                // if view is not in view hierarchy, performing batch updates will crash the app
                if collectionView.window == nil {
                    dataSource.setSections(newSections)
                    collectionView.reloadData()
                    return
                }
                let differences = try differencesForSectionedView(initialSections: oldSections, finalSections: newSections)
                
                var allUpdateItems: [ItemPath] = []
                if self.isAutoUpdate {
                    allUpdateItems = collectionView.indexPathsForVisibleItems.map({ ItemPath(sectionIndex: $0.section, itemIndex: $0.row) })
                }
                
                for difference in differences {
                    dataSource.setSections(difference.finalSections)
                    
                    if self.isAutoUpdate {
                        let removeItems = difference.deletedItems + difference.insertedItems
                        removeItems.forEach { deleteItemPath in
                            if let index = allUpdateItems.index(where: { $0 == deleteItemPath }) {
                                allUpdateItems.remove(at: index)
                            }
                        }
                    }
                    
                    collectionView.performBatchUpdates(difference, animationConfiguration: self.animationConfiguration)
                }
                if self.isAutoUpdate {
                    collectionView.performBatchUpdates({
                        let reloadItems = allUpdateItems.map({ IndexPath(row: $0.itemIndex, section: $0.sectionIndex) })
                        collectionView.reloadItems(at: reloadItems)
                    }, completion: { _ in
                    })
                }
                
            } catch {
                self.setSections(newSections)
                collectionView.reloadData()
            }
        }.on(event)
    }
    
    open func collectionView(_ collectionView: UICollectionView, observedEvent: Event<Element>) {
        
        if !throttledEventDidSet {
            throttledEventDidSet = true
            self.partialUpdateEvent
                .observeOn(MainScheduler.asyncInstance)
                .throttle(throttleTime, scheduler: MainScheduler.instance)
                .subscribe(onNext: { [weak self] event in
                    self?.collectionView(event.0, throttledObservedEvent: event.1)
                })
                .disposed(by: disposeBag)
        }
        
        UIBindingObserver(UIElement: self) { dataSource, newSections in
            if !self.isAnimated || !self.dataSet {
                self.dataSet = true
                dataSource.setSections(newSections)
                collectionView.reloadData()
            } else {
                let element = (collectionView, observedEvent)
                dataSource.partialUpdateEvent.on(.next(element))
            }
        }.on(observedEvent)
    }
}
