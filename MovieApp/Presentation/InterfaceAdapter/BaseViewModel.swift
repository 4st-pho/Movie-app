//
//  BaseViewModel.swift
//  MovieApp
//
//  Created by Rikkei on 15/04/2025.
//

import Foundation
import RxSwift
import Combine

class BaseViewModel: NSObject {
    var disposeBag = DisposeBag()
    var cancellables = Set<AnyCancellable>()
    
    func convertToCombinePublisher<T>(observable: Observable<Result<T, Error>>) -> AnyPublisher<Result<T, Error>, Never> {
        return Future<Result<T, Error>, Never> { [weak self] promise in
            observable.subscribe(onNext: { result in
                promise(.success(result))
            }, onError: { error in
                
            }).disposed(by: self?.disposeBag ?? DisposeBag())
        }
        .eraseToAnyPublisher()
    }
    
    deinit {
        #if DEBUG
        print("\(String(describing: self)) deinit")
        #endif
    }
}
