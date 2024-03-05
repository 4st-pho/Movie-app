import Foundation

protocol RegisterUseCase {
    func execute(
        requestValue: RegisterRequestValue,
        completion: @escaping (Result<Any?, Error>) -> Void
    )
}

final class DefaultRegisterUseCase: RegisterUseCase {
    private let authService: AuthService
    init(authService: AuthService = DefaultAuthService()) {
        self.authService = authService
    }

    func execute(requestValue: RegisterRequestValue, completion: @escaping (Result<Any?, Error>) -> Void) {
        return authService.register(email: requestValue.emai, username: requestValue.username, password: requestValue.password, completion: completion)
    }
}

struct RegisterRequestValue {
    let emai: String
    let password: String
    let username: String
}


