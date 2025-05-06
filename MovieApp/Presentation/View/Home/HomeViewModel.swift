import Foundation
import RxSwift
import RxCocoa

class HomeViewModel : BaseViewModel {
    let fetchNewestMoviesUsecase = AppDIContainer.resolve(FetchNewestMoviesUsecase.self)!
    let fetchPopularMoviesUsecase = AppDIContainer.resolve(FetchPoularMoviesUsecase.self)!
    let fetchPopularMoviesRequestValue = FetchMoviesUseCaseRequestValue(page: 1)
    let fetchNewestMoviesRequestValue = FetchMoviesUseCaseRequestValue(page: 1)
    
    struct Input {
        let firstLoadTrigger: Driver<Void>
        let showAppLoading: Driver<Bool>
    }
    
    struct Output {
        let loadingState: Driver<Bool>
        let error: Driver<String>
        let newestMovies: Driver<[Movie]>
        let popularMovies: Driver<[Movie]>
        let firstLoadFinish: Driver<Void>
    }
    
    
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = BehaviorRelay<String>(value: "")
    private let newestMoviesRelay = BehaviorRelay<[Movie]>(value: [])
    private let popularMoviesRelay = BehaviorRelay<[Movie]>(value: [])
    private let firstLoadFinishRelay = PublishRelay<Void>()
    
    func transform(input: Input) -> Output {
        listenFirstLoadTrigger(input: input)
        
        return Output(
            loadingState: loadingRelay.asDriverOnErrorJustComplete(),
            error: errorRelay.asDriverOnErrorJustComplete(),
            newestMovies: newestMoviesRelay.asDriverOnErrorJustComplete(),
            popularMovies: popularMoviesRelay.asDriverOnErrorJustComplete(),
            firstLoadFinish: firstLoadFinishRelay.asDriverOnErrorJustComplete()
        )
    }
    
    
    func listenFirstLoadTrigger(input: Input) {
        input.firstLoadTrigger.withLatestFrom(input.showAppLoading)
            .flatMapLatest { [weak self] showAppLoading -> Driver<((Result<[Movie], Error>, Bool), (Result<[Movie], Error>, Bool))> in
                guard let self  = self else { return .empty()}
                loadingRelay.accept(showAppLoading)
                let newest = self.fetchNewestMoviesUsecase.execute(requestValue: self.fetchNewestMoviesRequestValue).asDriverOnErrorJustComplete()
                let popular = self.fetchPopularMoviesUsecase.execute(requestValue: self.fetchPopularMoviesRequestValue).asDriverOnErrorJustComplete()
                return Driver.zip(newest, popular)
                    .map { (newest, popular) in
                        return (newest: newest, popular: popular)
                    }
            }.drive(onNext: { [weak self] newest, popular in
                guard let self  = self else { return }
                switch newest.0 {
                case .success(let movies):
                    newestMoviesRelay.accept(movies)
                case .failure(let error):
                    errorRelay.accept(Utils.localizedDescription(for: error))
                }
                switch popular.0 {
                case .success(let movies):
                    popularMoviesRelay.accept(movies)
                case .failure(let error):
                    errorRelay.accept(Utils.localizedDescription(for: error))
                }
                self.loadingRelay.accept(false)
                self.firstLoadFinishRelay.accept(())
            }).disposed(by: disposeBag)
        
    }
}
