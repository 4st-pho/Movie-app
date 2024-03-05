import Foundation

class ExploreMoviesViewModel: BaseViewModel {
    private var fetchMoviesRequestValue = FetchMoviesUseCaseRequestValue(page: 1)
    private lazy var fetchNewestMoviesUsecase : FetchNewestMoviesUsecase = DefaultFetchNewestMoviesUsecase()
    private lazy var fetchPopularMoviesUsecase : FetchPoularMoviesUsecase = DefaultFetchPoularMoviesUsecase()
    
    var loadingState: Observable<Bool>  = Observable(false)
    let error: Observable<String> = Observable("")
    var hasMoreData: Observable<Bool>  = Observable(false)
    let movies: Observable<[Movie]> = Observable([])
    var typeOfMoviesView: TypeOfMoviesView = .newest
    
    func load(showLoading: Bool = true) {
        self.loadingState.value = showLoading
        fetchMovie { [weak self] in
            self?.loadingState.value = false
        }
    }
    
    func fetchMovie(done: @escaping () -> Void) {
        switch typeOfMoviesView {
        case .newest:
            self.fetchNewestMoviesUsecase.execute(requestValue: fetchMoviesRequestValue)
            {  [weak self] cacheData in
                guard let self  = self else { return }
                if fetchMoviesRequestValue.page == 1 {
                    movies.value = cacheData
                }
            } completion : { [weak self] result in
                guard let self  = self else { return }
                done()
                switch result {
                case .success(let movies):
                    handleHasMoreData(result: movies)
                    if fetchMoviesRequestValue.page == 1{
                        self.movies.value = movies
                    } else{
                        self.movies.value.append(contentsOf: movies)
                    }
                case .failure(let error):
                    self.error.value = error.localizedDescription
                }
            }
        case .popular:
            self.fetchPopularMoviesUsecase.execute(requestValue: fetchMoviesRequestValue)
            {  [weak self] cacheData in
                guard let self  = self else { return }
                if fetchMoviesRequestValue.page == 1 {
                    movies.value = cacheData
                }
            } completion : { [weak self] result in
                guard let self  = self else { return }
                done()
                switch result {
                case .success(let movies):
                    handleHasMoreData(result: movies)
                    if fetchMoviesRequestValue.page == 1{
                        self.movies.value = movies
                    } else{
                        self.movies.value.append(contentsOf: movies)
                    }
                case .failure(let error):
                    self.error.value = error.localizedDescription
                }
                
            }
        }
    }
    
    func loadMore (){
        fetchMoviesRequestValue.increamentPage()
        fetchMovie(){}
    }
    
    private func handleHasMoreData(result: [Movie]){
        if result.isEmpty || result.count < fetchMoviesRequestValue.pageSize {
            hasMoreData.value = false
        }
        else {
            hasMoreData.value = true
        }
    }
}
