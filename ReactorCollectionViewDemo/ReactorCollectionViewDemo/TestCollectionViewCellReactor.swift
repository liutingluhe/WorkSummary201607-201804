//
//  TestCollectionViewCellReactor.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/5/18.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit

class TestCollectionViewCellReactor: BasicListItemModel, Reactor {
    
    typealias Action = NoAction
    
    struct State {
        var model: Model
    }
    
    var initialState: State
    
    init(model: Model) {
        initialState = State(model: model)
        super.init()
        identity = model.title
        cellSize = TestCollectionViewCell.Constraint.cellSize
    }
}
