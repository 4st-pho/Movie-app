import Foundation

protocol UpdateWatchListUsecase {
    func execute(
        watchListIds: [String],
        completion: @escaping (Result<User, Error>) -> Void
    )
}

final class DefaultUpdateWatchListUsecase: UpdateWatchListUsecase {
    private let userRepository: UserRepository
    init(userRepository: UserRepository = DefaultUserRepository()) {
        self.userRepository = userRepository
    }
    
    func execute(watchListIds: [String], completion: @escaping (Result<User, Error>) -> Void) {
        let uid = AppDataManager.shared.getCurrentUser()?.id ?? ""
        let watchList = ["watchList": watchListIds]
        return userRepository.updateUser(id: uid, data: watchList, completion: completion)
    }
}
