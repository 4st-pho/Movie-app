import Foundation

protocol FetchNewestMoviesUsecase {
    func execute(
        requestValue: FetchMoviesUseCaseRequestValue,
        cached: @escaping ([Movie]) -> Void,
        completion: @escaping (Result<[Movie], Error>) -> Void
    )
}

final class DefaultFetchNewestMoviesUsecase: FetchNewestMoviesUsecase {
    
    private let moviesRepository: MoviesRepository
    
    init(moviesRepository: MoviesRepository = DefaultMovieRepository()) {
        self.moviesRepository = moviesRepository
    }
    
    func execute(
        requestValue: FetchMoviesUseCaseRequestValue,
        cached: @escaping ([Movie]) -> Void,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ){
        return moviesRepository.fetchNewestMovies(
            page: requestValue.page,
            pageSize: requestValue.pageSize,
            cached: cached,
            completion: completion
        )
    }
    
}


