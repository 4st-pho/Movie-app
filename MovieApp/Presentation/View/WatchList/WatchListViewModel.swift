import Foundation
class WatchListViewModel: BaseViewModel {

    private let setWatchListIdsToLocalUseCase: SetWatchListIdsToLocalUseCase = DefaultSetWatchListIdsToLocalUseCase()
    private let fetchWatchListUseCase: FetchWatchListUsecase = DefaultFetchWatchListUsecase()
    private let updateWatchListUsecase: UpdateWatchListUsecase = DefaultUpdateWatchListUsecase()
    private lazy var getCurrentUserUseCase: GetCurrentUserUseCase = DefaultGetCurrentUserUseCase()
    lazy var isLoggedIn: Bool = getCurrentUserUseCase.execute() != nil
    var watchListIds: [String] = []
    
    var loadingState: Observable<Bool>  = Observable(false)
    let error: Observable<String> = Observable("")
    let watchList: Observable<[Movie]> = Observable([])
    
    func load(showLoading: Bool = true) {
        if isLoggedIn {
            self.loadingState.value = showLoading
            self.fetchWatchListUseCase.execute()
            {  cacheData in self.watchList.value = cacheData
            } completion : { [weak self] result in
                guard let self  = self else { return }
                loadingState.value = false
                switch result {
                case .success(let movies):
                    watchList.value = movies
                    watchListIds = movies.map{$0.id}
                    setWatchListIdsToLocal()
                case .failure(let error):
                    self.error.value = Utils.localizedDescription(for: error)
                }
            }
        }
    }
    
    func removeMovie(at index: Int){
        _ = watchListIds.remove(at: index)
    }
    
    func updateWatchList(){
        updateWatchListUsecase.execute(watchListIds: watchListIds) { [weak self] result in
            guard let self  = self else { return }
            switch result {
            case .success(_):
                setWatchListIdsToLocal()
                return
            case .failure(let error):
                self.error.value = Utils.localizedDescription(for: error)
            }
        }
    }
    
    private func setWatchListIdsToLocal() {
        setWatchListIdsToLocalUseCase.execute(watchListIds)
    }
}
