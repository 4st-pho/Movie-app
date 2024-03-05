import Foundation

protocol UpdateUserUseCase {
    func execute(
        data: [String: Any],
        file: Data?,
        completion: @escaping (Result<User, Error>) -> Void
    )
}

final class DefaultUpdateUserUseCase: UpdateUserUseCase {
    let appData = AppDataManager.shared
    func execute(data: [String : Any], file: Data?, completion: @escaping (Result<User, Error>) -> Void) {
        let uid = appData.getCurrentUser()?.id ?? ""
        return userRepository.updateUserWithImage(id: uid, data: data, file: file){ [weak self] result in
            guard let self  = self else { return }
            switch result {
            case .success(let data):
                appData.setCurrentUser(data)
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private let userRepository: UserRepository
    init(userRepository: UserRepository = DefaultUserRepository()) {
        self.userRepository = userRepository
    }
}
