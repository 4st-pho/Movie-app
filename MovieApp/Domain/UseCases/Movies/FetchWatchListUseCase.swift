import Foundation
import RxSwift

protocol FetchWatchListUsecase {
    func execute() -> Observable<Result<[Movie], Error>>
}

final class DefaultFetchWatchListUsecase: FetchWatchListUsecase {
    func execute() -> Observable<Result<[Movie], Error>> {
        return Observable.create { [weak self] signal in
            self?.userRepository.fetchWatchList(userId: self?.appData.getCurrentUser()?.id ?? "") { movies in
                signal.onNext(.success(movies))
            } completion: { result in
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
    
    func execute(
        cached: @escaping ([Movie]) -> Void,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ){
        print("uid: \(appData.getCurrentUser()?.id ?? "")")
        print("token: \(AppConfiguration.getCurrentToken())")
        return userRepository.fetchWatchList(
            userId: appData.getCurrentUser()?.id ?? "",
            cached: cached,
            completion: completion
        )
    }
    
}
