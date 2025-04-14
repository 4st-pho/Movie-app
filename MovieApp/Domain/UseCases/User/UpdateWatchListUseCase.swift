import Foundation

protocol UpdateWatchListUsecase {
    func execute(
        watchListIds: [String],
        completion: @escaping (Result<User, Error>) -> Void
    )
}

final class DefaultUpdateWatchListUsecase: UpdateWatchListUsecase {
    private let userRepository: UserRepository
    private let appData: AppDataManager
    init(userRepository: UserRepository, appData: AppDataManager) {
        self.userRepository = userRepository
        self.appData = appData
    }
    
    func execute(watchListIds: [String], completion: @escaping (Result<User, Error>) -> Void) {
        let uid = appData.getCurrentUser()?.id ?? ""
        let watchList = ["watchList": watchListIds]
        return userRepository.updateUser(id: uid, data: watchList, completion: completion)
    }
}
