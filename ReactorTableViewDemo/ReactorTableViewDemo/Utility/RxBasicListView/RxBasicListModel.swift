//
//  RxBasicListItem.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/6/21.
//  Copyright © 2018年 luhe liu. All rights reserved.
// swiftlint:disable operator_whitespace

import UIKit
import RxDataSources

public typealias RxBasicListModel = AnimatableSectionModel<RxBasicListSection, RxBasicListItem>

extension AnimatableSectionModel where Section: RxBasicListSection, ItemType: RxBasicListItem {
    public func transform(to items: [RxBasicListItem]) -> RxBasicListModel {
        return RxBasicListModel(model: self.model, items: items)
    }
}

extension Array where Element == RxBasicListModel {
    public func model(in indexPath: IndexPath) -> RxBasicListItem? {
        if let section = self.safeIndex(indexPath.section) {
            if let item = section.items.safeIndex(indexPath.row) {
                return item
            }
        }
        return nil
    }
}

// MARK: - 基础的列表元素模型
open class RxBasicListItem: IdentifiableType, Equatable {
    open var identity: String = ""
    open var cellSize: CGSize = .zero
    open var didSelected: Bool = false
    open var canSelected: Bool = true
    
    public static func ==(lhs: RxBasicListItem, rhs: RxBasicListItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}

// MARK: - 基础的列表组模型
open class RxBasicListSection: IdentifiableType, Equatable {
    open var totalCount: Int = 0
    open var canLoadMore: Bool = false
    open var identity: String = ""
    open var headerSize: CGSize = .zero
    open var footerSize: CGSize = .zero
    
    public init(totalCount: Int = 0, canLoadMore: Bool = false) {
        self.totalCount = totalCount
        self.canLoadMore = canLoadMore
    }
    
    public static func ==(lhs: RxBasicListSection, rhs: RxBasicListSection) -> Bool {
        return lhs.identity == rhs.identity
    }
}
