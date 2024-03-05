import Foundation
import Alamofire

final class DefaultMovieRepository {
    private let apiClient: APIClient
    private let cache: MoviesStorage
    
    init(apiClient: APIClient = APIClient.shared, cache: MoviesStorage = MoviesStorage()) {
        self.apiClient = apiClient
        self.cache = cache
    }
}

extension DefaultMovieRepository : MoviesRepository{
    
    func searchMovies(
        title: String,
        page: Int,
        pageSize: Int,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) {
        DispatchQueue.global().async { [weak self] in
            guard let self  = self else { return }
            let params = ["title": title, "page": "\(page)", "pageSize": "\(pageSize)"]
            apiClient.request(endpoint: "/api/movies/search", parameters: params, encoding: URLEncoding.default) {
                (result : Result<[MovieDTO], Error> ) in
                switch result {
                case .success(let responseDTO):
                    completion(.success(responseDTO.map{$0.toDomain()}))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
        }
    }
    
    func fetchPopularMovies(
        page: Int,
        pageSize: Int,
        cached: @escaping ([Movie]) -> Void,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                if let cachedMoviesDTO = self?.cache.load(with: .popularMoviesCacheKey) {
                    cached(cachedMoviesDTO.map{$0.toDomain()})
                }
            }
            apiClient.request(endpoint: "/api/popular-movies?page=\(page)&pageSize=\(pageSize)"){ (result : Result<[MovieDTO], Error> ) in
                switch result {
                case .success(let responseDTO):
                    DispatchQueue.main.async { [weak self] in
                        self?.cache.save(object: responseDTO, with: .popularMoviesCacheKey)
                    }
                    completion(.success(responseDTO.map{$0.toDomain()}))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchNewestMovies(
        page: Int = 1,
        pageSize: Int,
        cached: @escaping ([Movie]) -> Void,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                if let cachedMoviesDTO = self?.cache.load(with: .newestMoviesCacheKey) {
                    cached(cachedMoviesDTO.map{$0.toDomain()})
                }
            }
            apiClient.request(endpoint: "/api/movies?page=\(page)&pageSize=\(pageSize)"){ (result : Result<[MovieDTO], Error> ) in
                switch result {
                case .success(let responseDTO):
                    DispatchQueue.main.async { [weak self] in
                        self?.cache.save(object: responseDTO, with: .newestMoviesCacheKey)
                    }
                    completion(.success(responseDTO.map{$0.toDomain()}))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchComments(page: Int, pageSize: Int, movieId: String, completion: @escaping (Result<[Comment], Error>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            apiClient.request(endpoint: "/api/comments/\(movieId)?page=\(page)&pageSize=\(pageSize)"){ (result : Result<[CommentDTO], Error> ) in
                switch result {
                case .success(let responseDTO):
                    completion(.success(responseDTO.map{$0.toDomain()}))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func addComment(data: [String : Any], completion: @escaping (Result<Any?, Error>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            apiClient.request(endpoint: "/api/comments", method: .post, parameters: data){ (result : Result<EmptyResponse, Error> ) in
                switch result {
                case .success(_):
                    completion(.success(nil))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
