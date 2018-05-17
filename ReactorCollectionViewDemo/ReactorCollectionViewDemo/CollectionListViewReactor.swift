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

class TestListService: BasicCollectionService {
    override func request(page: Int) -> Observable<Result<[SectionType]>> {
        var sections = [SectionType]()
        let sectionModel = BasicListSectionModel(totalCount: 10, canLoadMore: true)
        let items = (0..<10).map({ _ in TestCellReactor(id: Int(arc4random_uniform(1200302))) })
        let section = SectionType(model: sectionModel, items: items)
        sections.append(section)
        print("request \(page)")
        return Observable.just(.success(sections)).delay(3, scheduler: MainScheduler.instance)
    }
}

class TestCellReactor: BasicListItemModel, Reactor {
    
    typealias Action = NoAction
    
    struct State {
        var id: Int = 0
    }
    
    var initialState: State = State()
    
    init(id: Int) {
        super.init()
        initialState.id = id
        identity = "\(id)"
        cellSize = CGSize(width: 50, height: 50)
    }
}

class CollectionListViewReactor: Reactor {
    
    typealias Action = NoAction
    
    struct State {
        var isRefresh: Bool = true
    }
    
    var collectionReactor: BasicCollectionViewReactor
    var initialState: State = State()
    
    init() {
        let service = TestListService()
        collectionReactor = BasicCollectionViewReactor(service: service)
    }
}
