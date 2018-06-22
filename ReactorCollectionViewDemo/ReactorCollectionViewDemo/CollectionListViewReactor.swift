//
//  CollectionListViewReactor.swift
//  RxTodo
//
//  Created by luhe liu on 2018/5/16.
//  Copyright © 2018年 Suyeol Jeon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit

class TestListService: RxBasicCollectionService {
    
    override init() {
        super.init()
        var newSections = [SectionType]()
        let sectionModel = RxBasicListSection(totalCount: 10, canLoadMore: false)
        let items = (0..<20).map({ _ -> TestCollectionViewCellReactor in
            let model = Model()
            model.title = "\(Int(arc4random_uniform(1200302)))"
            return TestCollectionViewCellReactor(service: self, model: model)
        })
        let section = SectionType(model: sectionModel, items: items)
        newSections.append(section)
        sections = newSections
    }
    
    /// 模拟网络请求
    override func request(page: Int, sections: [SectionType]) -> Observable<Result<[SectionType]>> {
        var newSections = [SectionType]()
        let sectionModel = RxBasicListSection(totalCount: 10, canLoadMore: page < 5)
        let items = (0..<20).map({ _ -> TestCollectionViewCellReactor in
            let model = Model()
            model.title = "\(Int(arc4random_uniform(1200302)))"
            return TestCollectionViewCellReactor(service: self, model: model)
        })
        let section = SectionType(model: sectionModel, items: items)
        newSections.append(section)
        print("request \(page)")
        return Observable.just(.success(newSections))
            .delay(3, scheduler: MainScheduler.instance)
    }
    
    deinit {
        print("TestListService dealloc")
    }
}

class CollectionListViewReactor: Reactor {
    
    typealias Action = NoAction
    
    struct State {
        var isRefresh: Bool = true
    }
    
    var collectionReactor: RxBasicCollectionViewReactor
    var initialState: State = State()
    let service = TestListService()
    
    init() {
        collectionReactor = RxBasicCollectionViewReactor(service: service)
        collectionReactor.headerRefreshReactor?.loadingReactor = RxBasicLoadingReactor(totalValue: 50, isOpenTimer: true)
    }
    
    deinit {
        print("CollectionListViewReactor dealloc")
    }
}
