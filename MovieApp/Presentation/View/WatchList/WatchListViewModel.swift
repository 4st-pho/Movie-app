import Foundation
import RxSwift
import RxCocoa

class WatchListViewModel: BaseViewModel {

    private let setWatchListIdsToLocalUseCase = AppDIContainer.resolve(SetWatchListIdsToLocalUseCase.self)!
    private let fetchWatchListUseCase = AppDIContainer.resolve(FetchWatchListUsecase.self)!
    private let updateWatchListUsecase = AppDIContainer.resolve(UpdateWatchListUsecase.self)!
    private lazy var getCurrentUserUseCase = AppDIContainer.resolve(GetCurrentUserUseCase.self)!
    private var watchListIds: [String] = []
    
    
    struct Input {
        let firstLoadTrigger: Driver<Void>
        let removeMovieAtIndex: Driver<Int>
    }
    
    struct Output {
        let loadingState: Driver<Bool>
        let error: Driver<String>
        let watchList: Driver<[Movie]>
        let isLoggedIn: Driver<Bool>
    }
    
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let isLoggedInRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = BehaviorRelay<String>(value: "")
    private let watchListRelay = BehaviorRelay<[Movie]>(value: [])
    
    func transform(input: Input) -> Output {
        listenFirstLoad(input: input)
        listenRemoveMovieFromWatchList(input: input)
        
        return Output(
            loadingState: loadingRelay.asDriverOnErrorJustComplete(),
            error: errorRelay.asDriverOnErrorJustComplete(),
            watchList: watchListRelay.asDriverOnErrorJustComplete(),
            isLoggedIn: isLoggedInRelay.asDriverOnErrorJustComplete()
        )
    }
    
    private func listenFirstLoad(input: Input) {
        
        input.firstLoadTrigger.asObservable().flatMapLatest{ [weak self] _ -> Observable<User?> in
            guard let self = self else { return .empty() }
            return self.getCurrentUserUseCase.execute()
        }.map{$0 != nil}.subscribe { isLoggedIn in
            self.isLoggedInRelay.accept(isLoggedIn)
        }.disposed(by: disposeBag)
        
        input.firstLoadTrigger.asObservable().skip(until: isLoggedInRelay).do { _ in
            if self.isLoggedInRelay.value {
                self.loadingRelay.accept(true)
            }
        }.flatMapLatest { _ -> Observable<Result<[Movie], Error>> in
            return self.fetchWatchListUseCase.execute()
        }.subscribe { result in
            switch result {
            case .success(let movies):
                self.watchListRelay.accept(movies)
                self.watchListIds = movies.map{$0.id}
                
            case .failure(let error):
                self.errorRelay.accept(Utils.localizedDescription(for: error))
            }
            self.loadingRelay.accept(false)
        }.disposed(by: disposeBag)
    }
        
    
    private func listenRemoveMovieFromWatchList(input: Input) {
        input.removeMovieAtIndex
            .flatMap { [weak self] index -> Driver<Result<User, any Error>> in
                guard let self  = self else { return .empty()}
                watchListIds.remove(at: index)
                return updateWatchListUsecase.execute(watchListIds: watchListIds).asDriverOnErrorJustComplete()
            }
            .drive { [weak self] result in
                guard let self  = self else { return }
                switch result {
                case .success(_):
                    setWatchListIdsToLocal()
                case .failure(let error):
                    errorRelay.accept(Utils.localizedDescription(for: error))
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func setWatchListIdsToLocal() {
        setWatchListIdsToLocalUseCase.execute(watchListIds)
    }
}
