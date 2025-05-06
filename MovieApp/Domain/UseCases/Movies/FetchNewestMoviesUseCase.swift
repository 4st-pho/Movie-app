import Foundation
import RxSwift

protocol FetchNewestMoviesUsecase {
    func execute(requestValue: FetchMoviesUseCaseRequestValue) -> Observable<(Result<[Movie], Error>, fromCache: Bool)>
}

final class DefaultFetchNewestMoviesUsecase: FetchNewestMoviesUsecase {
    
    private let moviesRepository: MoviesRepository
    
    init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }
    
    func execute(requestValue: FetchMoviesUseCaseRequestValue) -> Observable<(Result<[Movie], Error>, fromCache: Bool)> {
        return Observable.create { [weak self] signal in
            self?.moviesRepository.fetchNewestMovies(
                page: requestValue.page,
                pageSize: requestValue.pageSize) { movies in
                    signal.onNext((.success(movies), true))
                } completion: { result in
                    signal.onNext((result, false))
                    signal.onCompleted()
                }
            return Disposables.create()
        }
    }
    
}


