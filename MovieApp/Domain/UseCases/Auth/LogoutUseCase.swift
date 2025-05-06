import Foundation
import RxSwift

protocol LogOutUseCase {
    func execute() -> Observable<Result<Any?, Error>>
}

final class DefaultLogOutUseCase: LogOutUseCase {
    
    
    private let authService: AuthService
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func execute() -> Observable<Result<Any?, Error>> {
        return Observable.create { [weak self] signal in
            self?.authService.logOut() { result in
                switch result {
                case .success(_):
                    AppConfiguration.setCurrentToken("")
                    signal.onNext(result)
                case .failure(_):
                    signal.onNext(result)
                }
                signal.onCompleted()
            }
            return Disposables.create()
        }
    }
}
