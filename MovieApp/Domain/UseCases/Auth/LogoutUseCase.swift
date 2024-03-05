import Foundation

protocol LogOutUseCase {
    func execute( completion: @escaping (Result<Any?, Error>) -> Void)
}

final class DefaultLogOutUseCase: LogOutUseCase {
    private let authService: AuthService
    init(authService: AuthService = DefaultAuthService()) {
        self.authService = authService
    }

    func execute(completion: @escaping (Result<Any?, Error>) -> Void) {
        return authService.logOut() { result in
                switch result {
                case .success(_):
                    AppConfiguration.setCurrentToken("")
                    completion(result)
                case .failure(_):
                    completion(result)
            }
        }
    }
}
