import Foundation
import RxSwift
import RxCocoa

class MovieDetailViewModel: BaseViewModel {
    enum WatchListAction {
        case add
        case remove
    }
    
    private let fetchCommentsUseCase = AppDIContainer.resolve(FetchCommentsUseCase.self)!
    private var fetchCommentsRequestValue = FetchCommentsRequestValue(page: 1, movieId: "")
    private lazy var getLocalWatchListIdsUseCase = AppDIContainer.resolve(GetLocalWatchListIdsUseCase.self)!
    private let setWatchListIdsToLocalUseCase = AppDIContainer.resolve(SetWatchListIdsToLocalUseCase.self)!
    private lazy var getCurrentUserUseCase = AppDIContainer.resolve(GetCurrentUserUseCase.self)!
    private lazy var addToWatchListUseCase = AppDIContainer.resolve(AddToWatchListUseCase.self)!
    private lazy var addCommentUseCase = AppDIContainer.resolve(AddCommentUseCase.self)!
    private lazy var removeFromWatchListUseCase = AppDIContainer.resolve(RemoveFromWatchListUseCase.self)!
    private lazy var user = getCurrentUserUseCase.execute()
    private var debounceTimer: Timer?
    
    struct Input {
        let checLoggedIn: Driver<Void>
        let toggleSaveToWatchList: Driver<(String, WatchListAction)>
        let checkMovieContainInWatchList: Driver<String>
        let loadCommentsTrigger: Driver<String>
        let addCommentsTrigger: Driver<(movieId: String, content: String)>
    }
    
    struct Output {
        let loadingState: Driver<Bool>
        let error: Driver<String>
        let comments: Driver<[Comment]>
        let isMovieInWatchList: Driver<Bool>
        let isLoggedIn: Driver<Bool>
        let toggleSaveToWatchListCompletion: Driver<Void>
    }
    
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = BehaviorRelay<String>(value: "")
    private let commentsRelay = BehaviorRelay<[Comment]>(value: [])
    private let isMovieInWatchListRelay = BehaviorRelay<Bool>(value: false)
    private let isLoggedInRelay = BehaviorRelay<Bool>(value: false)
    private let toggleSaveToWatchListCompletion = PublishRelay<Void>()
    private let currentUserRelay = BehaviorRelay<User?>(value: nil)
    private let loadCommentsTrigger =  PublishRelay<String>()
    
    func transform(input: Input) -> Output {
        input.checkMovieContainInWatchList
            .flatMapLatest { [weak self] id -> Driver<Bool> in
                guard let self  = self else { return .empty()}
                return isMovieInWatchList(movieId: id).asDriverOnErrorJustComplete()
            }
            .drive(isMovieInWatchListRelay)
            .disposed(by: disposeBag)
        
        listenLoadComments(input: input)
        
        listenToggleSaveToWatchList(input: input)
        
        getCurrentUserUseCase.execute().bind(to: currentUserRelay).disposed(by: disposeBag)
        input.checLoggedIn.drive { [weak self] _ in
            self?.checkLoggedIn(input: input) {}
        }.disposed(by: disposeBag)
        
        listenAddComment(input: input)
        
        
        return Output(
            loadingState: loadingRelay.asDriverOnErrorJustComplete(),
            error: errorRelay.asDriverOnErrorJustComplete(),
            comments: commentsRelay.asDriverOnErrorJustComplete(),
            isMovieInWatchList: isMovieInWatchListRelay.asDriverOnErrorJustComplete(),
            isLoggedIn: isLoggedInRelay.asDriverOnErrorJustComplete(),
            toggleSaveToWatchListCompletion: toggleSaveToWatchListCompletion.asDriverOnErrorJustComplete()
        )
    }
    
    // Load comments after movie has value
    func listenLoadComments(input: Input){
        Driver.merge([input.loadCommentsTrigger, loadCommentsTrigger.asDriverOnErrorJustComplete()])
            .flatMap { [weak self] id -> Driver<Result<[Comment], any Error>> in
            guard let self  = self else { return .empty()}
            fetchCommentsRequestValue.movieId = id
            return fetchCommentsUseCase.execute(requestValue: fetchCommentsRequestValue).asDriverOnErrorJustComplete()
        }
        .drive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let comments):
                commentsRelay.accept(comments)
            case .failure(_):
                return
            }
        }
        .disposed(by: disposeBag)
    }
    
    func isMovieInWatchList(movieId: String) -> Observable<Bool> {
        return getLocalWatchListIdsUseCase.execute().map { ids in
            ids.contains(movieId)
        }
    }
    
    func checkLoggedIn(input: Input, completion: @escaping () -> Void) {
        guard let _ = currentUserRelay.value else {
            errorRelay.accept("You must loggin first")
            isLoggedInRelay.accept(false)
            return
        }
        isLoggedInRelay.accept(true)
    }
    
    func listenToggleSaveToWatchList(input: Input) {
        input.toggleSaveToWatchList
            .do(onNext: { [weak self] _ in
                self?.toggleSaveToWatchListCompletion.accept(())
            })
            .asObservable()
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged { previous, current in
                return previous.0 == current.0 && previous.1 == current.1
            }
            .flatMapLatest { [weak self] (movieId, action) -> Observable<Void> in
                guard let self = self else { return Observable.empty() }

                // Kiểm tra người dùng đã đăng nhập chưa
                guard let user = self.currentUserRelay.value else {
                    self.errorRelay.accept("You must log in first")
                    self.isLoggedInRelay.accept(false)
                    return .empty()
                }

                let requestValue = WatchListActionRequestValue(userId: user.id, movieId: movieId)

                // Lấy danh sách watchlist hiện tại
                return self.getLocalWatchListIdsUseCase.execute()
                    .flatMap { [weak self] ids -> Observable<Void> in
                        guard let self = self else { return Observable.empty() }

                        var updatedIds = ids
                        switch action {
                        case .add:
                            // Nếu chưa có trong watchlist, thêm vào
                            if !updatedIds.contains(movieId) {
                                updatedIds.append(movieId)
                                self.setWatchListIdsToLocalUseCase.execute(updatedIds)
                                return self.addToWatchListUseCase.execute(requestValue: requestValue)
                                    .map { _ in () }
                                    .catch { error in
                                        self.errorRelay.accept(Utils.localizedDescription(for: error))
                                        return .empty()
                                    }
                            }
                        case .remove:
                            // Nếu có trong watchlist, xóa đi
                            updatedIds.removeAll { $0 == movieId }
                            self.setWatchListIdsToLocalUseCase.execute(updatedIds)
                            return self.removeFromWatchListUseCase.execute(requestValue: requestValue)
                                .map { _ in () }
                                .catch { error in
                                    self.errorRelay.accept(Utils.localizedDescription(for: error))
                                    return .empty()
                                }
                        }
                        return Observable.empty()
                    }
            }.subscribe { _ in
                
            }.disposed(by: disposeBag)
    }
    
    private func listenAddComment(input: Input) {
        input.addCommentsTrigger
            .flatMapLatest({ [weak self] (movieId, content) -> Driver<Void> in
                guard let self  = self else { return .empty()}
                return self.addCommentUseCase.execute(movieId: movieId, content: content).asDriverOnErrorJustComplete()
                    .flatMap { [self, movieId] result in
                        switch result {
                        case .success(_):
                            self.loadCommentsTrigger.accept(movieId)
                        case .failure(let error):
                            _ = Utils.localizedDescription(for: error)
                        }
                        return .empty()
                    }
            })
            .drive()
            .disposed(by: disposeBag)
    }
    
}
