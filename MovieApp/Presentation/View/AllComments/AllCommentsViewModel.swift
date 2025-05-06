import Foundation
import RxSwift
import RxCocoa

class AllCommentsViewModel: BaseViewModel, ViewModelTransformable {
    var fetchCommentsRequestValue = FetchCommentsRequestValue(page: 1, pageSize: 20, movieId: "");
    private var fetchCommentsUseCase  = AppDIContainer.resolve(FetchCommentsUseCase.self)!
    
    struct Input {
        let firstTimeLoad: Driver<Void>
        let loadMoreTrigger: Driver<Void>
        let movieId: Driver<String>
    }
    
    struct Output {
        let loadingState: Driver<Bool>
        let error: Driver<String>
        let hasMoreData: Driver<Bool>
        let comments: Driver<[Comment]>
    }
    
    
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = BehaviorRelay<String>(value: "")
    private let hasMoreDataRelay = BehaviorRelay<Bool>(value: false)
    private let commentsRelay = BehaviorRelay<[Comment]>(value: [])
    
    func transform(input: Input) -> Output {
        listenFirstLoad(input: input)
        listenLoadMore(input: input)
        
        return Output (
            loadingState: loadingRelay.asDriverOnErrorJustComplete(),
            error: errorRelay.asDriverOnErrorJustComplete(),
            hasMoreData: hasMoreDataRelay.asDriverOnErrorJustComplete(),
            comments: commentsRelay.asDriverOnErrorJustComplete()
        )
    }
    
    func listenFirstLoad(input: Input) {
        input.firstTimeLoad.withLatestFrom(input.movieId)
            .flatMap ({ [weak self] movieId -> Driver<Void> in
                guard let self  = self else { return .empty()}
                self.fetchCommentsRequestValue.movieId = movieId
                self.loadingRelay.accept(true)
                return self.fetchComments(input: input).asDriverOnErrorJustComplete()
            }).drive(onNext: { [weak self] in
                self?.loadingRelay.accept(false)
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchComments(input: Input) -> Observable<Void> {
        return fetchCommentsUseCase.execute(requestValue: fetchCommentsRequestValue).flatMap { [weak self] result -> Observable<Void> in
            guard let self  = self else { return .empty()}
            switch result {
            case .success(let comments):
                handleHasMoreData(input: input, result: comments)
                if fetchCommentsRequestValue.page == 1 {
                    self.commentsRelay.accept(comments)
                } else{
                    self.commentsRelay.accept(self.commentsRelay.value + comments)
                }
            case .failure(let error):
                self.errorRelay.accept(Utils.localizedDescription(for: error))
            }
            return .just(())
        }
    }
    
    private func listenLoadMore (input: Input) {
        input.loadMoreTrigger
            .flatMap { [weak self] _ -> Driver<Void> in
                guard let self = self else { return .empty()}
                fetchCommentsRequestValue.increamentPage()
                return self.fetchComments(input: input).asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: disposeBag)
    }
    
    private func handleHasMoreData(input: Input, result: [Comment]){
        let isNotHasMoreData = result.isEmpty || result.count < fetchCommentsRequestValue.pageSize
        hasMoreDataRelay.accept(isNotHasMoreData)
        
    }
}
