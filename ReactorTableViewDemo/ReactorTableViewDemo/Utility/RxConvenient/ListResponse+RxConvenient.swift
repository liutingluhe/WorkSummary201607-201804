//
//  ListResponse+RxConvenient.swift
//  ifanr
//
//  Created by luhe liu on 2018/6/28.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import UIKit
import RxSwift

public typealias ObservableResultAnyList<T> = Observable<Result<AnyListResponse<T>>>
public typealias ObservableResultMappableList<T: Mappable> = Observable<Result<MappableListResponse<T>>>

open class MappleListHandler {
    open class func listMap(object: BasicListResponse?, data: NSDictionary) {
    }
}

open class BasicListResponse: RxBasicListSection, Mappable {
    
    open var listHandlerType: MappleListHandler.Type {
        return MappleListHandler.self
    }
    open var dicts: [NSDictionary] = []
    
    public override init(totalCount: Int, canLoadMore: Bool) {
        super.init(totalCount: totalCount, canLoadMore: canLoadMore)
    }
    
    public required init?(data: NSDictionary) {
        super.init()
        listHandlerType.listMap(object: self, data: data)
    }
    
    public func transform<OtherType>(to objects: [OtherType]) -> AnyListResponse<OtherType> {
        let result = AnyListResponse<OtherType>(
            items: objects,
            totalCount: self.totalCount,
            canLoadMore: self.canLoadMore
        )
        return result
    }
}

open class AnyListResponse<T>: BasicListResponse {
    
    open var items: [T] = []
    
    public init(items: [T] = [], totalCount: Int = 0, canLoadMore: Bool = false) {
        self.items = items
        super.init(totalCount: totalCount, canLoadMore: canLoadMore)
    }
    
    public required init?(data: NSDictionary) {
        super.init(data: data)
    }
}

open class MappleItemHandler {
    open class func itemMap<ModelType: Mappable>(object: MappableListResponse<ModelType>?, data: NSDictionary, isBasicMap: Bool = false) {
        guard let object = object else { return }
        object.items = object.dicts.flatMap({ (dict) -> ModelType? in
            if isBasicMap {
                return ModelType.basicMap(data: dict) as? ModelType
            }
            return ModelType.init(data: dict)
        })
    }
}

open class MappableListResponse<ModelType: Mappable>: AnyListResponse<ModelType> {
    
    open var itemHandlerType: MappleItemHandler.Type {
        return MappleItemHandler.self
    }
    
    public override init(items: [ModelType] = [], totalCount: Int = 0, canLoadMore: Bool = false) {
        super.init(totalCount: totalCount, canLoadMore: canLoadMore)
        self.items = items
    }
    
    public required init?(data: NSDictionary, isBasicMap: Bool = false) {
        super.init(data: data)
        itemHandlerType.itemMap(object: self, data: data, isBasicMap: isBasicMap)
    }
    
    public convenience required init?(data: NSDictionary) {
        self.init(data: data, isBasicMap: false)
    }
}
