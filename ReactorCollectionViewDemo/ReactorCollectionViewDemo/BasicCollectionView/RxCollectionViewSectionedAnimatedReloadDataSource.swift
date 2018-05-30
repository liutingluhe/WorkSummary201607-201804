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

/// 继承 RxCollectionViewSectionedReloadDataSource，实现一个可以进行列表动画的数据源
open class RxCollectionViewSectionedAnimatedReloadDataSource<S: AnimatableSectionModelType>
    : RxCollectionViewSectionedReloadDataSource<S> {
    
    public var animationConfiguration = AnimationConfiguration()
    var dataSet = false
    private let disposeBag = DisposeBag()
    private let partialUpdateEvent = PublishSubject<(UICollectionView, Event<Element>)>()
    
    public override init() {
        super.init()
        
        self.partialUpdateEvent
            .observeOn(MainScheduler.asyncInstance)
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] event in
                self?.collectionView(event.0, throttledObservedEvent: event.1)
            })
            .disposed(by: disposeBag)
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
                for difference in differences {
                    dataSource.setSections(difference.finalSections)
                    
                    collectionView.performBatchUpdates(difference, animationConfiguration: self.animationConfiguration)
                }
            } catch {
                self.setSections(newSections)
                collectionView.reloadData()
            }
        }.on(event)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, observedEvent: Event<Element>) {
        UIBindingObserver(UIElement: self) { dataSource, newSections in
            if !self.dataSet {
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
