import Foundation

protocol FetchWatchListUsecase {
    func execute(
        cached: @escaping ([Movie]) -> Void,
        completion: @escaping (Result<[Movie], Error>) -> Void
    )
}

final class DefaultFetchWatchListUsecase: FetchWatchListUsecase {
    
    private let userRepository: UserRepository
    private let appData: AppDataManager
    
    init(userRepository: UserRepository, appData: AppDataManager) {
        self.userRepository = userRepository
        self.appData = appData
    }
    
    func execute(
        cached: @escaping ([Movie]) -> Void,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ){
        print("uid: \(appData.getCurrentUser()?.id ?? "")")
        print("token: \(AppConfiguration.getCurrentToken())")
        return userRepository.fetchWatchList(
            userId: appData.getCurrentUser()?.id ?? "",
            cached: cached,
            completion: completion
        )
    }
    
}
