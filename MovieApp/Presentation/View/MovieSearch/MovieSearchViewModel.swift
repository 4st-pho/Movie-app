import Foundation
import UIKit
class MovieSearchViewModel : BaseViewModel {
    
    private let searchMoviesUsecase: SearchMoviesUseCase = DefaultSearchMoviesUseCase()
    private lazy var getCurrentUserUseCase: GetCurrentUserUseCase = DefaultGetCurrentUserUseCase()
    private var searchRequestValue = SearchMoviesUseCaseRequestValue(title: "", page: 1)
    private var debounceTimer: Timer?
    lazy var currentUser = getCurrentUserUseCase.execute()
    var loadingState: Observable<Bool>  = Observable(false)
    var hasMoreData: Observable<Bool>  = Observable(false)
    let searchResult: Observable<[Movie]?> = Observable(nil)
    let error: Observable<String> = Observable("")
    
    func load(showLoading : Bool = false) {
        search(keyword: "", loadFromCache: true, enableDebounce: false)
    }
    
    func search(keyword: String, loadFromCache: Bool = false, enableDebounce: Bool = true) {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: enableDebounce ? 1 : 0, repeats: false) { [weak self] _ in
            guard let self  = self else { return }
            searchRequestValue.updateRequestValue(title: keyword, page: 1)
            searchMoviesUsecase.execute(requestValue: searchRequestValue) {result in
                switch result{
                case .success(let movies):
                    self.handleHasMoreData(result: movies)
                    self.searchResult.value = movies
                case .failure(let error):
                    self.error.value = Utils.localizedDescription(for: error)
                }
            }
        }
    }
    
    func loadMore (){
        searchRequestValue.increamentPage()
        searchMoviesUsecase.execute(requestValue: searchRequestValue) { [weak self] result in
            guard let self  = self else { return }
            switch result{
            case .success(let movies):
                handleHasMoreData(result: movies)
                self.searchResult.value?.append(contentsOf: movies)
            case .failure(let error):
                self.error.value = Utils.localizedDescription(for: error)
            }
        }
    }
    
    private func handleHasMoreData(result: [Movie]){
        if result.isEmpty || result.count < searchRequestValue.pageSize {
            hasMoreData.value = false
        }
        else {
            hasMoreData.value = true
        }
    }
}
