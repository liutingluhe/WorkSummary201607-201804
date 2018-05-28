//
//  BasicCollectionRefreshView.swift
//  ReactorCollectionViewDemo
//
//  Created by luhe liu on 2018/5/18.
//  Copyright © 2018年 luhe liu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

open class BasicLoadingView: UIView, View {
    
    open var disposeBag = DisposeBag()
    open var indicatorView: UIActivityIndicatorView!
    fileprivate var indicatorViewStyle: UIActivityIndicatorViewStyle = .gray
    
    public init(frame: CGRect, style: UIActivityIndicatorViewStyle = .gray) {
        super.init(frame: frame)
        self.indicatorViewStyle = style
        setupSubviews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    open func setupSubviews() {
        indicatorView = UIActivityIndicatorView(activityIndicatorStyle: indicatorViewStyle)
        indicatorView.center = CGPoint(x: self.frame.size.width * 0.5, y: self.frame.size.height * 0.5)
        self.addSubview(indicatorView)
    }
    
    open func bind(reactor: BasicLoadingReactor) {
        reactor.state.asObservable()
            .map({ $0.isLoading })
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .bind(to: indicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
    }

}
