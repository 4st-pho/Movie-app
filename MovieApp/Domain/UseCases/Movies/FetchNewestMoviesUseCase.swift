import Foundation
import Combine

protocol FetchNewestMoviesUsecase {
    func execute(requestValue: FetchMoviesUseCaseRequestValue) -> AnyPublisher<(Result<[Movie], Error>, fromCache: Bool), Never>
}

final class DefaultFetchNewestMoviesUsecase: FetchNewestMoviesUsecase {
    
    private let moviesRepository: MoviesRepository
    
    init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }
    
    func execute(requestValue: FetchMoviesUseCaseRequestValue) -> AnyPublisher<(Result<[Movie], Error>, fromCache: Bool), Never> {
        let subject = PassthroughSubject<(Result<[Movie], Error>, fromCache: Bool), Never>()
        
        moviesRepository.fetchNewestMovies(
            page: requestValue.page,
            pageSize: requestValue.pageSize
        ) { movies in
            subject.send((.success(movies), true))
        } completion: { result in
            subject.send((result, false))
            subject.send(completion: .finished)
        }
        return subject.eraseToAnyPublisher()
    }
    
}


