//
//  HomeViewModel.swift
//  MovieApp
//
//  Created by Rikkei on 14/05/2025.
//

import Foundation

class HomeViewModel: BaseViewModel, ObservableObject {
    // MARK: - Private Properties
    let fetchNewestMoviesUsecase = AppDIContainer.resolve(FetchNewestMoviesUsecase.self)!
    let fetchPopularMoviesUsecase = AppDIContainer.resolve(FetchPoularMoviesUsecase.self)!
    let fetchPopularMoviesRequestValue = FetchMoviesUseCaseRequestValue(page: 1)
    let fetchNewestMoviesRequestValue = FetchMoviesUseCaseRequestValue(page: 1)
    
    // MARK: - Published Properties
    @Published var popularMovies: [Movie] = []
    @Published var newestMovies: [Movie] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    
    override init() {
        super.init()
        fetchMovies()
    }
    
    func fetchMovies() {
        isLoading = true
        fetchNewestMoviesUsecase
            .execute(requestValue: fetchNewestMoviesRequestValue)
            .combineLatest(fetchPopularMoviesUsecase.execute(requestValue: fetchPopularMoviesRequestValue))
            .sink {[weak self]  _ in
                self?.isLoading = false
            } receiveValue: { [weak self] newestMoviesResult, popularMoviesResult in
                guard let self  = self else { return }
                switch (newestMoviesResult.0, popularMoviesResult.0) {
                case (.success(let newestMovies),  .success(let popularMovies) ) :
                    self.newestMovies = newestMovies
                    self.popularMovies = popularMovies
                case (.failure(let error), _):
                    errorMessage = Utils.localizedDescription(for: error)
                case (_, .failure(let error)):
                    errorMessage = Utils.localizedDescription(for: error)
                }
            }.store(in: &cancellables)
    }
}
