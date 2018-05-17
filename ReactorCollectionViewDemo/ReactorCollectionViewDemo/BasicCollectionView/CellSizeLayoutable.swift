//
//  CellSizeLayoutable.swift
//  RxTodo
//
//  Created by luhe liu on 2018/5/17.
//  Copyright © 2018年 Suyeol Jeon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

protocol CellSizeLayoutable {
    var dataSource: RxCollectionViewSectionedReloadDataSource<BasicListModel> { get set }
    func getCellSize(indexPath: IndexPath) -> CGSize
    func getFooterSize(section: Int) -> CGSize
    func getHeaderSize(section: Int) -> CGSize
}

extension CellSizeLayoutable {
    func getCellSize(indexPath: IndexPath) -> CGSize {
        if let section = dataSource.sectionModels.safeIndex(indexPath.section) {
            if let item = section.items.safeIndex(indexPath.row) {
                return item.cellSize
            }
        }
        return .zero
    }
    
    func getFooterSize(section: Int) -> CGSize {
        return .zero
    }
    
    func getHeaderSize(section: Int) -> CGSize {
        return .zero
    }
}
