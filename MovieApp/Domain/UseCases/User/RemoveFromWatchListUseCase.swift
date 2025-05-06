import Foundation
import RxSwift

protocol RemoveFromWatchListUseCase {
    @discardableResult
    func execute(
        requestValue: WatchListActionRequestValue
    ) -> Observable<Result<Any?, Error>>
}

final class DefaultRemoveFromWatchListUseCase: RemoveFromWatchListUseCase {
    private let userRepository: UserRepository
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    @discardableResult
    func execute(requestValue: WatchListActionRequestValue) -> Observable<Result<Any?, Error>> {
        return Observable.create { signal in
            self.userRepository.removeFromWatchList(userId: requestValue.userId, movieId: requestValue.movieId) { result in
                signal.onNext(result)
                signal.onCompleted()
            }
            return Disposables.create()
        }
    }
}
