import Foundation
import RxSwift

protocol RegisterUseCase {
    func execute(requestValue: RegisterRequestValue) -> Observable<Result<Any?, Error>>
}

final class DefaultRegisterUseCase: RegisterUseCase {
    private let authService: AuthService
    init(authService: AuthService) {
        self.authService = authService
    }

    func execute(requestValue: RegisterRequestValue) -> Observable<Result<Any?, Error>> {
        return Observable.create { signal in
            self.authService.register(email: requestValue.emai, username: requestValue.username, password: requestValue.password) { result in
                signal.onNext(result)
                signal.onCompleted()
            }
            return Disposables.create()
        }
    }
}

struct RegisterRequestValue {
    let emai: String
    let password: String
    let username: String
}


