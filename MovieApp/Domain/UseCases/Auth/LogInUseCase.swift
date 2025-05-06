import Foundation
import RxSwift

protocol LogInUseCase {
    func execute(requestValue: LoginRequestValue) -> Observable<Result<(token: String, user: User), Error>>
}

final class DefaultLogInUseCase: LogInUseCase {
    
    func execute(requestValue: LoginRequestValue) -> Observable<Result<(token: String, user: User), Error>> {
        return Observable.create { signal in
            self.authService.logIn(email: requestValue.emai, password: requestValue.password) { result in
                switch result {
                case .success(let data):
                    self.appData.setCurrentUser(data.user)
                    AppConfiguration.setCurrentToken(data.token)
                    signal.onNext(result)
                case .failure(_):
                    signal.onNext(result)
                }
                signal.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    private let authService: AuthService
    private let appData: AppDataManager
    init(authService: AuthService, appData: AppDataManager) {
        self.authService = authService
        self.appData = appData
    }
}

struct LoginRequestValue {
    let emai: String
    let password: String
}


