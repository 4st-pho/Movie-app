import Foundation
import RxSwift

protocol UpdateWatchListUsecase {
    func execute(
        watchListIds: [String]
    ) -> Observable<Result<User, Error>>
}

final class DefaultUpdateWatchListUsecase: UpdateWatchListUsecase {
    func execute(watchListIds: [String]) -> Observable<Result<User, Error>> {
        return Observable.create { [weak self] signal in
            let uid = self?.appData.getCurrentUser()?.id ?? ""
            let watchList = ["watchList": watchListIds]
            self?.userRepository.updateUser(id: uid, data: watchList) { result in
                signal.onNext(result)
                signal.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    private let userRepository: UserRepository
    private let appData: AppDataManager
    init(userRepository: UserRepository, appData: AppDataManager) {
        self.userRepository = userRepository
        self.appData = appData
    }
    
    func execute(watchListIds: [String], completion: @escaping (Result<User, Error>) -> Void) {
        let uid = appData.getCurrentUser()?.id ?? ""
        let watchList = ["watchList": watchListIds]
        return userRepository.updateUser(id: uid, data: watchList, completion: completion)
    }
}
