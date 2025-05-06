import Foundation
import RxSwift

protocol AddToWatchListUseCase {
    @discardableResult
    func execute(requestValue: WatchListActionRequestValue) -> Observable<Result<Any?, Error>>
}

final class DefaultAddToWatchListUseCase: AddToWatchListUseCase {
    private let userRepository: UserRepository
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    @discardableResult
    func execute(requestValue: WatchListActionRequestValue) -> Observable<Result<Any?, Error>> {
        return Observable.create { signal in
            self.userRepository.addToWatchList(userId: requestValue.userId, movieId: requestValue.movieId) { result in
                signal.onNext(result)
                signal.onCompleted()
            }
            return Disposables.create()
        }
    }
}
