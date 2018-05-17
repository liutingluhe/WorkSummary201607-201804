//
//  ListService.swift
//  RxTodo
//
//  Created by luhe liu on 2018/5/16.
//  Copyright © 2018年 Suyeol Jeon. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import RxCocoa
import RxDataSources
import ReactorKit

typealias Result = Alamofire.Result

extension Collection {
    /*
     let array = [1, 2, 3, 4]
     print(array.safeIndex(1)) // Optional 2
     print(array.safeIndex(88)) // Nil
     */
    func safeIndex(_ i: Int) -> Self.Iterator.Element? {
        
        guard !isEmpty && count > abs(i) else { return nil }
        
        for item in self.enumerated() {
            if item.offset == i {
                return item.element
            }
        }
        return nil
    }
}

typealias BasicListModel = AnimatableSectionModel<BasicListSectionModel, BasicListItemModel>

class BasicListItemModel: IdentifiableType, Equatable {
    var identity: String = ""
    var cellSize: CGSize = .zero
    var didSelected: Bool = false
    
    static func ==(lhs: BasicListItemModel, rhs: BasicListItemModel) -> Bool {
        return lhs.identity == rhs.identity
    }
}

class BasicListSectionModel: IdentifiableType, Equatable {
    var totalCount: Int = 0
    var canLoadMore: Bool = false
    var identity: String = ""
    
    init(totalCount: Int = 0, canLoadMore: Bool = false) {
        self.totalCount = totalCount
        self.canLoadMore = canLoadMore
    }

    static func ==(lhs: BasicListSectionModel, rhs: BasicListSectionModel) -> Bool {
        return lhs.identity == rhs.identity
    }
}

protocol ListServiceType {
    associatedtype IndexType: Hashable
    associatedtype ItemType: IdentifiableType & Equatable
    associatedtype Section: IdentifiableType
    typealias SectionType = AnimatableSectionModel<Section, ItemType>
    /// 获取本地缓存数据
    var localSections: [SectionType] { get }
    /// 列表请求
    func request(page: Int) -> Observable<Result<[SectionType]>>
    /// 列表排序
    func sort(sections: [SectionType]) -> [SectionType]
    /// 列表分组
    func group(sections: [SectionType]) -> [SectionType]
    /// 列表选中
    func select(indexs: [IndexType], sections: [SectionType]) -> [SectionType]
    /// 列表插入元素
    func insert(items: [IndexType: ItemType], sections: [SectionType]) -> [SectionType]
    /// 列表删除元素，根据具体要删除的元素
    func delete(items: [ItemType], sections: [SectionType]) -> [SectionType]
    /// 列表删除元素，根据要删除的索引
    func delete(indexs: [IndexType], sections: [SectionType]) -> [SectionType]
    /// 列表修改某个元素
    func update(items: [ItemType], sections: [SectionType]) -> [SectionType]
    /// 列表查找元素
    func find(index: IndexType, sections: [SectionType]) -> ItemType?
    /// 列表批量查找元素
    func find(indexs: [IndexType], sections: [SectionType]) -> [IndexType: ItemType]
    /// 批量合并多组的所有元素
    func mergeSections(_ oldSetions: [SectionType], with sections: [SectionType], page: Int) -> [SectionType]
    /// 合并一组的所有元素
    func mergeSection(_ oldSetion: SectionType, with section: SectionType, page: Int) -> SectionType
    /// 合并中对旧元素的更新操作
    func mergeUpdateItem(_ oldItem: ItemType, newItem: ItemType)
}

class BasicCollectionService: ListServiceType {
    
    typealias IndexType = IndexPath
    typealias ItemType = BasicListItemModel
    typealias Section = BasicListSectionModel
    typealias SectionType = AnimatableSectionModel<Section, ItemType>
    
    var deletedItemsCache: [ItemType] = []
    var needCacheDeleted: Bool = false
    
    /// 列表请求
    func request(page: Int) -> Observable<Result<[SectionType]>> {
        return .empty()
    }
    /// 列表排序
    func sort(sections: [SectionType]) -> [SectionType] {
        return sections
    }
    /// 列表分组
    func group(sections: [SectionType]) -> [SectionType] {
        return sections
    }
    /// 列表选中
    func select(indexs: [IndexType], sections: [SectionType]) -> [SectionType] {
        sections.forEach { (section) in
            section.items.forEach({ (item) in
                item.didSelected = false
            })
        }
        indexs.forEach { (index) in
            if let item = find(index: index, sections: sections) {
                item.didSelected = true
            }
        }
        return sections
    }
    /// 列表插入元素
    func insert(items: [IndexType: ItemType], sections: [SectionType]) -> [SectionType] {
        let soredItems = items.sorted(by: { $0.key < $1.key })
        var newSections: [SectionType] = sections
        soredItems.forEach { (key, value) in
            if var newSection = sections.safeIndex(key.section) {
                if key.item >= 0 && key.item < newSection.items.count {
                    var newItems = newSection.items
                    newItems.insert(value, at: key.item)
                    newSection.items = newItems
                    newSection.model.totalCount += 1
                    newSections[key.section] = newSection
                }
            }
        }
        return newSections
    }
    /// 列表删除元素，根据具体要删除的元素
    func delete(items: [ItemType], sections: [SectionType]) -> [SectionType] {
        var newSections: [SectionType] = []
        sections.forEach { (section) in
            var newSection = section
            var newItems: [ItemType] = []
            newSection.items.forEach({ (item) in
                if items.filter({ $0.identity == item.identity }).count == 0 {
                    newItems.append(item)
                } else {
                    if needCacheDeleted {
                        deletedItemsCache.append(item)
                    }
                    newSection.model.totalCount -= 1
                }
            })
            newSection.items = newItems
            newSections.append(newSection)
        }
        return newSections
    }
    /// 列表删除元素，根据要删除的索引
    func delete(indexs: [IndexType], sections: [SectionType]) -> [SectionType] {
        var newSections: [SectionType] = []
        for (sectionIndex, section) in sections.enumerated() {
            if indexs.filter({ $0.section == sectionIndex }).count > 0 {
                var newSection = section
                var newItems: [ItemType] = []
                for (itemIndex, item) in newSection.items.enumerated() {
                    if indexs.filter({ $0.section == sectionIndex && $0.item == itemIndex }).count == 0 {
                        newItems.append(item)
                    } else {
                        if needCacheDeleted {
                            deletedItemsCache.append(item)
                        }
                        newSection.model.totalCount -= 1
                    }
                }
                newSection.items = newItems
                newSections.append(newSection)
            } else {
                newSections.append(section)
            }
        }
        return newSections
    }
    /// 列表修改某个元素
    func update(items: [ItemType], sections: [SectionType]) -> [SectionType] {
        var newSections = sections
        for (sectionIndex, var section) in sections.enumerated() {
            var newItems = section.items
            for (itemIndex, oldItem) in section.items.enumerated() {
                if let newItem = items.filter({ $0.identity == oldItem.identity }).first {
                    newItems[itemIndex] = newItem
                }
            }
            section.items = newItems
            newSections[sectionIndex] = section
        }
        return newSections
    }
    /// 列表查找元素
    func find(index: IndexType, sections: [SectionType]) -> ItemType? {
        if let section = sections.safeIndex(index.section) {
            return section.items.safeIndex(index.item)
        }
        return nil
    }
    /// 列表批量查找元素
    func find(indexs: [IndexType], sections: [SectionType]) -> [IndexType: ItemType] {
        var result: [IndexType: ItemType] = [:]
        indexs.forEach { (index) in
            result[index] = find(index: index, sections: sections)
        }
        return result
    }
    /// 获取本地缓存数据
    var localSections: [SectionType] {
        return []
    }
    /// 批量合并多组的所有元素
    func mergeSections(_ oldSetions: [SectionType], with sections: [SectionType], page: Int) -> [SectionType] {
        var newSections: [SectionType] = []
        sections.forEach { (section) in
            if let oldSection = oldSetions.filter({ $0.model.identity == section.model.identity }).first {
                let newSection = mergeSection(oldSection, with: section, page: page)
                newSections.append(newSection)
            } else {
                newSections.append(section)
            }
        }
        return newSections
    }
    /// 合并一组的所有元素
    func mergeSection(_ oldSetion: SectionType, with section: SectionType, page: Int) -> SectionType {
        var newSection = oldSetion
        let currentItems = oldSetion.items
        // 过滤之前手动删除的 cell
        var filterItems = currentItems
        if needCacheDeleted {
            filterItems += deletedItemsCache
        }
        var newItems: [ItemType] = []
        section.items.forEach { item in
            if let oldItem = filterItems.filter({ return $0.identity == item.identity }).first {
                mergeUpdateItem(oldItem, newItem: item)
            } else {
                newItems.append(item)
            }
        }
        if page > 0 { // 加载更多是尾部递增，总数不变
            newSection.items = currentItems + newItems
            newSection.model.totalCount = max(section.model.totalCount, oldSetion.model.totalCount)
        } else { // 加载第一页是顶部递增, 并且总数增加
            newSection.items = newItems + currentItems
            newSection.model.totalCount = max(section.model.totalCount, oldSetion.model.totalCount + newItems.count)
        }
        newSection.model.totalCount = max(newSection.model.totalCount, newSection.items.count)
        newSection.model.canLoadMore = section.model.canLoadMore
        return newSection
    }
    /// 合并中对旧元素的更新操作
    func mergeUpdateItem(_ oldItem: ItemType, newItem: ItemType) {
    }
}
