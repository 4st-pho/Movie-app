//
//  BaseViewModel.swift
//  MovieApp
//
//  Created by Rikkei on 15/04/2025.
//

import Foundation
import RxSwift

class BaseViewModel: NSObject {
    internal var disposeBag: DisposeBag!
    
    override init() {
        self.disposeBag = DisposeBag()
    }
    
    deinit {
        #if DEBUG
        print("\(String(describing: self)) deinit")
        #endif
    }
}
