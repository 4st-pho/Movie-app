import Foundation
import RxSwift
import Combine

protocol FetchPoularMoviesUsecase {
    func execute(requestValue: FetchMoviesUseCaseRequestValue) -> AnyPublisher<(Result<[Movie], Error>, fromCache: Bool), Never>
}

final class DefaultFetchPoularMoviesUsecase: FetchPoularMoviesUsecase {
    private let moviesRepository: MoviesRepository
    
    init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }
    func execute(requestValue: FetchMoviesUseCaseRequestValue) -> AnyPublisher<(Result<[Movie], Error>, fromCache: Bool), Never> {
        let subject = PassthroughSubject<(Result<[Movie], Error>, fromCache: Bool), Never>()
        self.moviesRepository.fetchPopularMovies(
            page: requestValue.page,
            pageSize: requestValue.pageSize) { movies in
                subject.send((.success(movies), true))
            } completion: { result in
                subject.send((result, true))
                subject.send(completion: .finished)
            }
        return subject.eraseToAnyPublisher()
    }
}
