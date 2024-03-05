import Foundation

protocol SearchMoviesUseCase {
    func execute(
        requestValue: SearchMoviesUseCaseRequestValue,
        completion: @escaping (Result<[Movie], Error>) -> Void
    )
}

final class DefaultSearchMoviesUseCase: SearchMoviesUseCase {
    private let moviesRepository: MoviesRepository
    init(moviesRepository: MoviesRepository = DefaultMovieRepository()) {
        self.moviesRepository = moviesRepository
    }
    
    func execute(
        requestValue: SearchMoviesUseCaseRequestValue,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) {
        return moviesRepository.searchMovies(
            title: requestValue.title,
            page: requestValue.page,
            pageSize: requestValue.pageSize,
            completion: completion
        )
    }
}

struct SearchMoviesUseCaseRequestValue {
    var title: String
    var page: Int
    var pageSize: Int = 10
    
    mutating func updateRequestValue(title: String? = nil, page: Int? = nil){
        if let title = title {
            self.title = title
        }
        if let page = page {
            self.page = page
        }
    }
    mutating func increamentPage(){
        page += 1
    }
}
