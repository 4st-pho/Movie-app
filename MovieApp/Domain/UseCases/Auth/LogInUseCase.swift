import Foundation

protocol LogInUseCase {
    func execute(
        requestValue: LoginRequestValue,
        completion: @escaping (Result<(token: String, user: User), Error>) -> Void
    )
}

final class DefaultLogInUseCase: LogInUseCase {
    private let authService: AuthService
    init(authService: AuthService = DefaultAuthService()) {
        self.authService = authService
    }

    func execute(requestValue: LoginRequestValue, completion: @escaping (Result<(token: String, user: User), Error>) -> Void) {
        return authService.logIn(email: requestValue.emai, password: requestValue.password) { result in
            switch result {
            case .success(let data):
                AppDataManager.shared.setCurrentUser(data.user)
                AppConfiguration.setCurrentToken(data.token)
                print("token: \(data.token)")
                completion(result)
            case .failure(_):
                completion(result)
            }
        }
    }
}

struct LoginRequestValue {
    let emai: String
    let password: String
}


