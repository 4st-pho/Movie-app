import Foundation

protocol RemoveFromWatchListUseCase {
    func execute(
        requestValue: WatchListActionRequestValue,
        completion: @escaping (Result<Any?, Error>) -> Void
    )
}

final class DefaultRemoveFromWatchListUseCase: RemoveFromWatchListUseCase {
    private let userRepository: UserRepository
    init(userRepository: UserRepository = DefaultUserRepository()) {
        self.userRepository = userRepository
    }
    
    func execute(requestValue: WatchListActionRequestValue, completion: @escaping (Result<Any?, Error>) -> Void) {
        userRepository.removeFromWatchList(userId: requestValue.userId, movieId: requestValue.movieId, completion: completion)
    }
}
