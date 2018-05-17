//
//  RxCollectionViewDelegateLayoutSource.swift
//  ifanr
//
//  Created by luhe liu on 17/8/9.
//  Copyright © 2017年 ifanr. All rights reserved.
//

import UIKit

protocol Zeroable {
    static var zero: Self { get }
}

extension CGSize: Zeroable {
    
}

extension UIEdgeInsets: Zeroable {
    
}

extension CGFloat: Zeroable {
    static var zero: CGFloat {
        return 0.0
    }
}

class Layout<Input, Output: Zeroable> {
    var factory: (Input) -> Output = { _ in
        return Output.zero
    }
    
    func at(_ index: Input) -> Output {
        return factory(index)
    }
}

class CollectionViewLayoutSource {
    
    typealias SizeForCellFactory = (IndexPath) -> CGSize
    typealias SupplementaryViewSizeFactory = (Int) -> CGSize
    typealias SpacingFactory = (Int) -> CGFloat
    typealias EdgeInsetsFactory = (Int) -> UIEdgeInsets
    
    var sizeForCell: Layout<IndexPath, CGSize> = Layout<IndexPath, CGSize>()
    var sizeForHeader: Layout<Int, CGSize>  = Layout<Int, CGSize>()
    var sizeForFooter: Layout<Int, CGSize>  = Layout<Int, CGSize>()
    var insetForSection: Layout<Int, UIEdgeInsets>  = Layout<Int, UIEdgeInsets>()
    var minLineSpacing: Layout<Int, CGFloat>  = Layout<Int, CGFloat>()
    var minInteritemSpacing: Layout<Int, CGFloat>  = Layout<Int, CGFloat>()
    
    var configureSizeForCell: SizeForCellFactory? {
        didSet {
            if let configureSizeForCell = configureSizeForCell {
                sizeForCell.factory = configureSizeForCell
            }
        }
    }
    var configureHeaderSize: SupplementaryViewSizeFactory? {
        didSet {
            if let configureHeaderSize = configureHeaderSize {
                sizeForHeader.factory = configureHeaderSize
            }
        }
    }
    var configureFooterSize: SupplementaryViewSizeFactory? {
        didSet {
            if let configureFooterSize = configureFooterSize {
                sizeForFooter.factory = configureFooterSize
            }
        }
    }
    var configureMinLineSpacing: SpacingFactory? {
        didSet {
            if let configureMinLineSpacing = configureMinLineSpacing {
                minLineSpacing.factory = configureMinLineSpacing
            }
        }
    }
    var configureMinInteritemSpacing: SpacingFactory? {
        didSet {
            if let configureMinInteritemSpacing = configureMinInteritemSpacing {
                minInteritemSpacing.factory = configureMinInteritemSpacing
            }
        }
    }
    var configureInsetForSection: EdgeInsetsFactory? {
        didSet {
            if let configureInsetForSection = configureInsetForSection {
                insetForSection.factory = configureInsetForSection
            }
        }
    }
}
