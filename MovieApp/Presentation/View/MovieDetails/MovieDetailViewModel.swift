import Foundation
class MovieDetailViewModel: BaseViewModel {
    enum WatchListAction{
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
    
    var loadingState: Observable<Bool>  = Observable(false)
    let error: Observable<String> = Observable("")
    let comments: Observable<[Comment]> = Observable([])
    
    func load(showLoading: Bool = false) {
        
    }
    
    // Load comments after movie has value
    func loadComments(movieId: String){
        fetchCommentsRequestValue.movieId = movieId
        fetchCommentsUseCase.execute(requestValue: fetchCommentsRequestValue) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let comments):
                self.comments.value = comments
            case .failure(_):
                return
            }
            
        }
    }
    
    func isMovieInWatchList(movieId: String) -> Bool {
        return getLocalWatchListIdsUseCase.execute().contains(movieId)
    }
    
    func checkLoggedIn(completion: @escaping () -> Void) {
        guard let _ = user else {
            error.value = "You must loggin first"
            return
        }
        completion()
    }
    
    func toggleSaveToWatchList(movieId: String, action: WatchListAction, completion: @escaping () -> Void ){
        checkLoggedIn(){ [weak self] in
            guard let self  = self else { return }
            completion()
            debounceTimer?.invalidate()
            debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                let requestValue = WatchListActionRequestValue(userId: self.user?.id ?? "", movieId: movieId)
                switch action {
                case .add:
                    self.addToWatchList(requestValue: requestValue)
                case .remove:
                    self.removeFromWatchList(requestValue: requestValue)
                }
            }
        }
    }
    
    private func addToWatchList(requestValue: WatchListActionRequestValue){
        var ids = getLocalWatchListIdsUseCase.execute()
        ids.append(requestValue.movieId)
        setWatchListIdsToLocalUseCase.execute(ids)
        
        addToWatchListUseCase.execute(requestValue: requestValue) { result in
            switch result {
            case .success(_): return
            case .failure(let error):
                _ = Utils.localizedDescription(for: error)
                
            }
        }
    }
    
    private func removeFromWatchList(requestValue: WatchListActionRequestValue){
        var ids = getLocalWatchListIdsUseCase.execute()
        ids.removeAll{$0 == requestValue.movieId}
        setWatchListIdsToLocalUseCase.execute(ids)
        
        removeFromWatchListUseCase.execute(requestValue: requestValue) { result in
            switch result {
            case .success(_): return
            case .failure(let error):
                _ = Utils.localizedDescription(for: error)
            }
        }
    }
    
    func addComment(movieId: String, content: String) {
        addCommentUseCase.execute(movieId: movieId, content: content){ [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                loadComments(movieId: movieId)
            case .failure(_):
                return
            }}
    }
    
}
