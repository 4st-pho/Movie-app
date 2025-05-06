import Foundation
import RxSwift

protocol FetchCommentsUseCase {
    func execute(
        requestValue: FetchCommentsRequestValue
    ) -> Observable<Result<[Comment], Error>>
}

final class DefaultFetchCommentsUseCase: FetchCommentsUseCase {
    func execute(requestValue: FetchCommentsRequestValue) -> RxSwift.Observable<Result<[Comment], Error>> {
        return Observable.create { signal in
            self.moviesRepository.fetchComments(
                page: requestValue.page,
                pageSize: requestValue.pageSize,
                movieId: requestValue.movieId)
            { result in
                signal.onNext(result)
                signal.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    private let moviesRepository: MoviesRepository
    
    init(moviesRepository: MoviesRepository) {
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


