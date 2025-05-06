import Foundation
import RxSwift

protocol GetCurrentUserUseCase {
    func execute() -> Observable<User?>
}

final class DefaultGetCurrentUserUseCase: GetCurrentUserUseCase {
    private let appData: AppDataManager
    init(appData: AppDataManager) {
        self.appData = appData
    }

    func execute() -> Observable<User?> {
        return Observable.create { [weak self] signal in
            signal.onNext(self?.appData.getCurrentUser())
            signal.onCompleted()
            return Disposables.create()
        }
    }
}
