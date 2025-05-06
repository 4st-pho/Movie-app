import Foundation
import RxSwift

protocol GetLocalWatchListIdsUseCase {
    func execute() -> Observable<[String]>
}

final class DefaultGetLocalWatchListIdsUseCase: GetLocalWatchListIdsUseCase {
    func execute() -> Observable<[String]> {
        return Observable.create { [weak self] signal in
            let data = self?.appData.getsWatchListIds() ?? []
            signal.onNext(data)
            return Disposables.create()
        }
    }
    
    private let appData: AppDataManager
    init(appData: AppDataManager) {
        self.appData = appData
    }
}
