import Foundation

protocol MoviesRepository {
    
    func fetchNewestMovies(
        page: Int,
        pageSize: Int,
        cached: @escaping ([Movie]) -> Void,
        completion: @escaping (Result<[Movie], Error>) -> Void
    )
    
    func fetchPopularMovies(
        page: Int,
        pageSize: Int,
        cached: @escaping ([Movie]) -> Void,
        completion: @escaping (Result<[Movie], Error>) -> Void
    )
    
    func searchMovies(
        title: String,
        page: Int,
        pageSize: Int,
        completion: @escaping (Result<[Movie], Error>) -> Void
    )
    
    func fetchComments(
        page: Int,
        pageSize: Int,
        movieId: String,
        completion: @escaping (Result<[Comment], Error>) -> Void
    )
    
    func addComment(
        data: [String: Any],
        completion: @escaping (Result<Any?, Error>) -> Void
    )
}


