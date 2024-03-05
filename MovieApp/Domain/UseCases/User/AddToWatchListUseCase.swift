import Foundation

protocol AddToWatchListUseCase {
    func execute(
        requestValue: WatchListActionRequestValue,
        completion: @escaping (Result<Any?, Error>) -> Void
    )
}

final class DefaultAddToWatchListUseCase: AddToWatchListUseCase {
    private let userRepository: UserRepository
    init(userRepository: UserRepository = DefaultUserRepository()) {
        self.userRepository = userRepository
    }
    
    func execute(requestValue: WatchListActionRequestValue, completion: @escaping (Result<Any?, Error>) -> Void) {
        userRepository.addToWatchList(userId: requestValue.userId, movieId: requestValue.movieId, completion: completion)
    }
}
