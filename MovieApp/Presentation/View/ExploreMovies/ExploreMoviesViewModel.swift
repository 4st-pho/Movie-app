import Foundation
import RxSwift
import RxCocoa

class ExploreMoviesViewModel: BaseViewModel {
    private var fetchMoviesRequestValue = FetchMoviesUseCaseRequestValue(page: 1)
    private lazy var fetchNewestMoviesUsecase = AppDIContainer.resolve(FetchNewestMoviesUsecase.self)!
    private lazy var fetchPopularMoviesUsecase = AppDIContainer.resolve(FetchPoularMoviesUsecase.self)!
    
    struct Input {
        let firstLoadTrigger: Driver<Void>
        let loadMoreTrigger: Driver<Void>
        let typeOfMoviesView: Driver<TypeOfMoviesView>
    }
    
    struct Output {
        let loadingState: Driver<Bool>
        let error: Driver<String>
        let hasMoreData: Driver<Bool>
        let movies: Driver<[Movie]>
    }
    
    
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let hasMoreDataRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = BehaviorRelay<String>(value: "")
    private let moviesRelay = BehaviorRelay<[Movie]>(value: [])
    private let typeOfMoviesViewRelay = BehaviorRelay<TypeOfMoviesView>(value: .newest)
    
    func transform(input: Input) -> Output {
        input.typeOfMoviesView.drive(typeOfMoviesViewRelay).disposed(by: disposeBag)
        listenFirstLoadTrigger(input: input)
        listenLoadMoreTrigger(input: input)
        
        return Output(
            loadingState: loadingRelay.asDriverOnErrorJustComplete(),
            error: errorRelay.asDriverOnErrorJustComplete(),
            hasMoreData: hasMoreDataRelay.asDriverOnErrorJustComplete(),
            movies: moviesRelay.asDriverOnErrorJustComplete()
        )
    }
    
    
    private func listenFirstLoadTrigger(input: Input) {
        input.firstLoadTrigger.do { _ in
            self.loadingRelay.accept(true)
        }.flatMapLatest { [weak self] _ -> Driver<(Result<[Movie], Error>, fromCache: Bool)> in
            guard let self  = self else { return .empty()}
            return self.fetchMovie(input: input).asDriverOnErrorJustComplete()
        }.drive { [weak self] result, fromCache in
            guard let self  = self else { return }
            switch result {
            case .success(let movies):
                handleHasMoreData(movies: movies)
                if fetchMoviesRequestValue.page == 1 {
                    moviesRelay.accept(movies)
                } else {
                    if !fromCache {
                        moviesRelay.accept(moviesRelay.value + movies)
                    }
                }
            case .failure(let error):
                errorRelay.accept(Utils.localizedDescription(for: error))
            }
            loadingRelay.accept(false)
        }.disposed(by: disposeBag)
    }
    
    private func fetchMovie(input: Input) -> Observable<(Result<[Movie], Error>, fromCache: Bool)> {
        switch typeOfMoviesViewRelay.value {
        case .newest:
            return self.fetchNewestMoviesUsecase.execute(requestValue: fetchMoviesRequestValue)
        case .popular:
            return self.fetchPopularMoviesUsecase.execute(requestValue: fetchMoviesRequestValue)
        }
    }
    
    func listenLoadMoreTrigger(input: Input){
        input.loadMoreTrigger
            .flatMapLatest { [weak self] _ -> Driver<(Result<[Movie], Error>, fromCache: Bool)> in
                guard let self  = self else { return .empty()}
                fetchMoviesRequestValue.increamentPage()
                return fetchMovie(input: input).asDriverOnErrorJustComplete()
            }.drive { [weak self] result, fromCache in
                guard let self  = self else { return }
                switch result {
                case .success(let movies):
                    handleHasMoreData(movies: movies)
                    if fetchMoviesRequestValue.page == 1 {
                        moviesRelay.accept(movies)
                    } else {
                        if !fromCache {
                            moviesRelay.accept(moviesRelay.value + movies)
                        }
                    }
                case .failure(let error):
                    errorRelay.accept(Utils.localizedDescription(for: error))
                }
            }.disposed(by: disposeBag)
    }
    
    private func handleHasMoreData(movies: [Movie]){
        if movies.isEmpty || movies.count < fetchMoviesRequestValue.pageSize {
            hasMoreDataRelay.accept(false)
        }
        else {
            hasMoreDataRelay.accept(true)
        }
    }
}
