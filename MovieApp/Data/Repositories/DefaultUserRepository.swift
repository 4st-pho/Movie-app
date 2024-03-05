
import Foundation

final class DefaultUserRepository {
    private let apiClient: APIClient
    private let cache: UserStorage
    private let movieCache: MoviesStorage
    
    init(apiClient: APIClient = APIClient.shared, cache: UserStorage = UserStorage(), movieCache: MoviesStorage = MoviesStorage()) {
        self.apiClient = apiClient
        self.cache = cache
        self.movieCache = movieCache
    }
}

extension DefaultUserRepository : UserRepository {
    func updateUser(id: String, data: [String : Any], completion: @escaping (Result<User, Error>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self  = self else { return }
            apiClient.request(endpoint: "/api/users/\(id)", method: .patch, parameters: data){ (result : Result<UserDTO, Error>) in
                switch result {
                case .success(let responseDTO):
                    self.cache.save(object: responseDTO)
                    completion(.success(responseDTO.toDomain()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    
    func updateUserWithImage(id: String, data: [String : Any], file: Data?, completion: @escaping (Result<User, Error>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self  = self else { return }
            apiClient.requestWithImageFile(endpoint: "/api/users/\(id)", method: .patch, parameters: data, file: file){ (result : Result<UserDTO, Error>) in
                switch result {
                case .success(let responseDTO):
                    self.cache.save(object: responseDTO)
                    completion(.success(responseDTO.toDomain()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func addToWatchList(userId: String, movieId: String, completion: @escaping (Result<Any?, Error>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self  = self else { return }
            let params = ["movieId": movieId, "userId": userId]
            apiClient.request(endpoint: "/api/users/add-to-watchlist", method: .post, parameters: params){ (result : Result<UserDTO, Error>) in
                switch result {
                case .success(let responseDTO):
                    self.cache.save(object: responseDTO)
                    completion(.success(nil))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func removeFromWatchList(userId: String, movieId: String, completion: @escaping (Result<Any?, Error>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self  = self else { return }
            let params = ["movieId": movieId, "userId": userId]
            apiClient.request(endpoint: "/api/users/remove-from-watchlist", method: .post, parameters: params){ (result : Result<UserDTO, Error>) in
                switch result {
                case .success(let responseDTO):
                    self.cache.save(object: responseDTO)
                    completion(.success(nil))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchWatchList(
        userId: String,
        cached: @escaping ([Movie]) -> Void,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) {
        DispatchQueue.global().async { [weak self] in
            guard let self  = self else { return }
            DispatchQueue.main.async {
                if let cachedMoviesDTO = self.movieCache.load(with: .watchList) {
                    cached(cachedMoviesDTO.map{$0.toDomain()})
                }
            }
            apiClient.request(endpoint: "/api/users/watchlist/\(userId)"){ (result : Result<[MovieDTO], Error>) in
                switch result {
                case .success(let responseDTO):
                    DispatchQueue.main.async {
                        self.movieCache.save(object: responseDTO, with: .watchList)
                    }
                    completion(.success(responseDTO.map{$0.toDomain()}))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
}
