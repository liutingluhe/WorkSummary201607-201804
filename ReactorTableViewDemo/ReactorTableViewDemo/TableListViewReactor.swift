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

var testValue: Int = 0

class TestListService: RxBasicListService {
    
    override init() {
        super.init()
        var newSections = [SectionType]()
        let sectionModel = RxBasicListSection(totalCount: 10, canLoadMore: false)
//        sectionModel.headerSize.height = 1
//        sectionModel.footerSize.height = 1
        let items = (0..<20).map({ _ -> TestTableViewCellReactor in
            let model = Model()
            model.title = "\(Int(arc4random_uniform(1200302)))"
            return TestTableViewCellReactor(service: self, model: model)
        })
        let section = SectionType(model: sectionModel, items: items)
        newSections.append(section)
        sections = newSections
    }
    
    /// 模拟网络请求
    override func request(page: Int, sections: [SectionType]) -> Observable<Result<[SectionType]>> {
        var newSections = [SectionType]()
        if testValue == 0 {
            let sectionModel = RxBasicListSection(totalCount: 20, canLoadMore: page < 3)
//            sectionModel.headerSize.height = 1
//            sectionModel.footerSize.height = 1
            let items = (0..<20).map({ _ -> TestTableViewCellReactor in
                let model = Model()
                model.title = "\(Int(arc4random_uniform(1200302)))"
                return TestTableViewCellReactor(service: self, model: model)
            })
            let section = SectionType(model: sectionModel, items: items)
            newSections.append(section)
        } else if testValue == 2 {
            testValue = (testValue + 1) % 3
            return Observable.just(.failure(NSError(domain: "dsa", code: 23, userInfo: nil)))
                .delay(3, scheduler: MainScheduler.instance)
        }
        testValue = (testValue + 1) % 3
        print("request \(page) \(testValue)")
        return Observable.just(.success(newSections))
            .delay(3, scheduler: MainScheduler.instance)
    }
    
    deinit {
        print("TestListService dealloc")
    }
}

class TableListViewReactor: Reactor {
    
    typealias Action = NoAction
    
    struct State {
        var isRefresh: Bool = true
    }
    
    var tableReactor: RxBasicTableViewReactor
    var initialState: State = State()
    let service = TestListService()
    
    init() {
        tableReactor = RxBasicTableViewReactor(service: service)
        tableReactor.headerRefreshReactor?.loadingReactor = RxBasicLoadingReactor(totalValue: 50, isOpenTimer: true)
    }
    
    deinit {
        print("CollectionListViewReactor dealloc")
    }
}
