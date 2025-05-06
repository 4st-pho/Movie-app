import Foundation
import UIKit
import RxSwift
import RxCocoa

class MovieSearchViewModel : BaseViewModel {
    
    private let searchMoviesUsecase = AppDIContainer.resolve(SearchMoviesUseCase.self)!
    private lazy var getCurrentUserUseCase = AppDIContainer.resolve(GetCurrentUserUseCase.self)!
    private var searchRequestValue = SearchMoviesUseCaseRequestValue(title: "", page: 1)
    private var debounceTimer: Timer?
    
    struct Input {
        let firstLoadTrigger: Driver<Void>
        let loadMoreTrigger: Driver<Void>
        let searchKeywordChange: Driver<String>
        
    }
    
    struct Output {
        let loadingState: Driver<Bool>
        let reloadApp: Driver<Bool>
        let error: Driver<String>
        let hasMoreData: Driver<Bool>
        let searchResult: Driver<[Movie]?>
        let currentUser: Driver<User?>
    }
    
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let reloadAppRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = BehaviorRelay<String>(value: "")
    private let hasMoreDataRelay = BehaviorRelay<Bool>(value: false)
    private let searchResultRelay = BehaviorRelay<[Movie]?>(value: nil)
    private let currentUserRelay = BehaviorRelay<User?>(value: nil)
    
    func transform(input: Input) -> Output {
        listenFirstLoad(input: input)
        listenSearch(input: input)
        listenLoadMore(input: input)
        
        
        return Output(
            loadingState: loadingRelay.asDriverOnErrorJustComplete(),
            reloadApp: reloadAppRelay.asDriverOnErrorJustComplete(),
            error: errorRelay.asDriverOnErrorJustComplete(),
            hasMoreData: hasMoreDataRelay.asDriverOnErrorJustComplete(),
            searchResult: searchResultRelay.asDriverOnErrorJustComplete(),
            currentUser: currentUserRelay.asDriverOnErrorJustComplete()
        )
    }
    
    private func listenFirstLoad(input: Input, showLoading : Bool = false) {
        input.firstLoadTrigger.flatMap { [weak self] _ -> Driver<User?> in
            guard let self  = self else { return .empty()}
            return getCurrentUserUseCase.execute().asDriverOnErrorJustComplete()
        }.drive { [weak self] user in
            self?.currentUserRelay.accept(user)
        }.disposed(by: disposeBag)
    }
    
    private func listenSearch(input: Input) {
        input.searchKeywordChange
            .distinctUntilChanged()
            .debounce(DispatchTimeInterval.seconds(1))
            .flatMapLatest({ [weak self] keyword -> Driver<Result<[Movie], Error>> in
                guard let self  = self else { return .empty()}
                self.searchRequestValue.updateRequestValue(title: keyword, page: 1)
                return self.searchMoviesUsecase
                    .execute(requestValue: self.searchRequestValue)
                    .asDriverOnErrorJustComplete()
            })
            .drive {[weak self] result in
                guard let self  = self else { return }
                switch result{
                case .success(let movies):
                    self.handleHasMoreData(result: movies)
                    self.searchResultRelay.accept(movies)
                case .failure(let error):
                    self.errorRelay.accept(Utils.localizedDescription(for: error))
                    
                }
            }.disposed(by: disposeBag)
    }
    
    private func listenLoadMore (input: Input) {
        input.loadMoreTrigger
            .flatMapLatest({ [weak self] _ ->  Driver<Result<[Movie], Error>> in
                guard let self = self else { return .empty()}
                self.searchRequestValue.increamentPage()
                return searchMoviesUsecase.execute(requestValue: searchRequestValue).asDriverOnErrorJustComplete()
            }).drive { [weak self]  result in
                switch result{
                case .success(let movies):
                    guard !movies.isEmpty else { return }
                    self?.handleHasMoreData(result: movies)
                    var currentMovies = self?.searchResultRelay.value ?? []
                    currentMovies.append(contentsOf: movies)
                    self?.searchResultRelay.accept(currentMovies)
                case .failure(let error):
                    self?.errorRelay.accept(Utils.localizedDescription(for: error))
                }
            }.disposed(by: disposeBag)
    }
    
    private func handleHasMoreData(result: [Movie]) {
        let isNotHasMoreData = result.isEmpty || result.count < searchRequestValue.pageSize
        hasMoreDataRelay.accept(!isNotHasMoreData)
    }
}
