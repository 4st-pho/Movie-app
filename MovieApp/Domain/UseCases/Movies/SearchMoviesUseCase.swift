import Foundation
import RxSwift

protocol SearchMoviesUseCase {
    func execute(requestValue: SearchMoviesUseCaseRequestValue) -> Observable<Result<[Movie], Error>>
}

final class DefaultSearchMoviesUseCase: SearchMoviesUseCase {
    private let moviesRepository: MoviesRepository
    init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }
    
    func execute(requestValue: SearchMoviesUseCaseRequestValue) -> Observable<Result<[Movie], Error>> {
        return Observable.create { signal in
            self.moviesRepository.searchMovies(
                title: requestValue.title,
                page: requestValue.page,
                pageSize: requestValue.pageSize) { result in
                    signal.onNext(result)
                    signal.onCompleted()
                }
            return Disposables.create()
        }
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
