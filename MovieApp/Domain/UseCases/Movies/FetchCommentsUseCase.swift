import Foundation

protocol FetchCommentsUseCase {
    func execute(
        requestValue: FetchCommentsRequestValue,
        completion: @escaping (Result<[Comment], Error>) -> Void
    )
}

final class DefaultFetchCommentsUseCase: FetchCommentsUseCase {
    private let moviesRepository: MoviesRepository
    
    init(moviesRepository: MoviesRepository = DefaultMovieRepository()) {
        self.moviesRepository = moviesRepository
    }
    
    func execute(
        requestValue: FetchCommentsRequestValue,
        completion: @escaping (Result<[Comment], Error>) -> Void
    ){
        return moviesRepository.fetchComments(
            page: requestValue.page,
            pageSize: requestValue.pageSize,
            movieId: requestValue.movieId,
            completion: completion
        )
    }
    
}


