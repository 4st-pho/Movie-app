//
//  UIScrollViewExtension.swift
//  MovieApp
//
//  Created by MACBOOK PRO on 3/5/25.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIScrollView {
    func bindContentHeight(to constraint: NSLayoutConstraint) -> Disposable {
        return observe(CGSize.self, "contentSize")
            .compactMap { $0?.height }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { height in
                constraint.constant = height
            })
    }
}
