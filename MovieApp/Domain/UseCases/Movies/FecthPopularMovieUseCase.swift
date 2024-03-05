import Foundation
import Foundation

protocol FetchPoularMoviesUsecase {
    func execute(
        requestValue: FetchMoviesUseCaseRequestValue,
        cached: @escaping ([Movie]) -> Void,
        completion: @escaping (Result<[Movie], Error>) -> Void
    )
}

final class DefaultFetchPoularMoviesUsecase: FetchPoularMoviesUsecase {
    
    private let moviesRepository: MoviesRepository
    
    init(moviesRepository: MoviesRepository = DefaultMovieRepository()) {
        self.moviesRepository = moviesRepository
    }
    
    func execute(
        requestValue: FetchMoviesUseCaseRequestValue,
        cached: @escaping ([Movie]) -> Void,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ){
        return moviesRepository.fetchPopularMovies(
            page: requestValue.page,
            pageSize: requestValue.pageSize,
            cached: cached,
            completion: completion
        )
    }
}
