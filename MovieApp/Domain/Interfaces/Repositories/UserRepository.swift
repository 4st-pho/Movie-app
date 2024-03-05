import Foundation

protocol UserRepository {
    func updateUser(
        id: String,
        data: [String : Any],
        completion: @escaping (Result<User, Error>) -> Void
    )
    
    func updateUserWithImage(
        id: String,
        data: [String : Any],
        file: Data?,
        completion: @escaping (Result<User, Error>) -> Void
    )
    
    func addToWatchList(
        userId: String,
        movieId: String,
        completion: @escaping (Result<Any?, Error>) -> Void
    )
    
    func removeFromWatchList(
        userId: String,
        movieId: String,
        completion: @escaping (Result<Any?, Error>) -> Void
    )
    
    func fetchWatchList(
        userId: String,
        cached: @escaping ([Movie]) -> Void,
        completion: @escaping (Result<[Movie], Error>) -> Void
    )
    
}
