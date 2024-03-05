import Foundation
import UIKit
class HomeViewModel : BaseViewModel {
    let fetchNewestMoviesUsecase : FetchNewestMoviesUsecase = DefaultFetchNewestMoviesUsecase()
    let fetchPopularMoviesUsecase : FetchPoularMoviesUsecase = DefaultFetchPoularMoviesUsecase()
    let fetchPopularMoviesRequestValue = FetchMoviesUseCaseRequestValue(page: 1)
    let fetchNewestMoviesRequestValue = FetchMoviesUseCaseRequestValue(page: 1)
    
    var loadingState: Observable<Bool>  = Observable(false)
    let newestMovies: Observable<[Movie]> = Observable([])
    let popularMovies: Observable<[Movie]> = Observable([])
    let error: Observable<String> = Observable("")
    
    func load(showLoading: Bool = true, completion: (() -> Void)? = nil){
        self.loadingState.value = showLoading
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        self.fetchNewestMoviesUsecase.execute(requestValue: fetchNewestMoviesRequestValue)
        {  [weak self] cacheData in self?.newestMovies.value = cacheData
        } completion : { [weak self] result in
            guard let self  = self else { return }
            
            switch result {
            case .success(let movies):
                self.newestMovies.value = movies
            case .failure(let error):
                self.error.value = error.localizedDescription
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        self.fetchPopularMoviesUsecase.execute( requestValue: fetchPopularMoviesRequestValue)
        { [weak self] cacheData in self?.popularMovies.value = cacheData
        } completion : { [weak self] result in
            guard let self  = self else { return }
            
            switch result {
            case .success(let movies):
                self.popularMovies.value = movies
            case .failure(let error):
                print(error)
                self.error.value = Utils.localizedDescription(for: error)
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.loadingState.value = false
            if let completion = completion { completion() }
        }
    }
}
