//
//  ServicesAssembly.swift
//  MovieApp
//
//  Created by Rikkei on 14/04/2025.
//

import Foundation
import Swinject

final class ServicesAssembly: Assembly {
    func assemble(container: Swinject.Container) {
        container.register(UpdateUserUseCase.self) { r in
            DefaultUpdateUserUseCase(
                userRepository: r.resolve(UserRepository.self)!,
                appData: r.resolve(AppDataManager.self)!
            )
        }.inObjectScope(.transient)
        
        container.register(FetchCommentsUseCase.self) { r in
            DefaultFetchCommentsUseCase(moviesRepository: r.resolve(MoviesRepository.self)!)
        }.inObjectScope(.transient)
        
        container.register(GetLocalWatchListIdsUseCase.self) { r in
            DefaultGetLocalWatchListIdsUseCase(appData: r.resolve(AppDataManager.self)!)
        }.inObjectScope(.transient)
        
        container.register(SearchMoviesUseCase.self) { r in
            DefaultSearchMoviesUseCase(moviesRepository: r.resolve(MoviesRepository.self)!)
        }.inObjectScope(.transient)
        
        container.register(GetCurrentUserUseCase.self) { r in
            DefaultGetCurrentUserUseCase(appData: r.resolve(AppDataManager.self)!)
        }.inObjectScope(.transient)
        
        container.register(RegisterUseCase.self) { r in
            DefaultRegisterUseCase(authService: r.resolve(AuthService.self)!)
        }.inObjectScope(.transient)
        
        container.register(FetchNewestMoviesUsecase.self) { r in
            DefaultFetchNewestMoviesUsecase(moviesRepository: r.resolve(MoviesRepository.self)!)
        }.inObjectScope(.transient)
        
        container.register(FetchPoularMoviesUsecase.self) { r in
            DefaultFetchPoularMoviesUsecase(moviesRepository: r.resolve(MoviesRepository.self)!)
        }.inObjectScope(.transient)
        
        container.register(LogOutUseCase.self) { r in
            DefaultLogOutUseCase(authService: r.resolve(AuthService.self)!)
        }.inObjectScope(.transient)
        
        container.register(RemoveFromWatchListUseCase.self) { r in
            DefaultRemoveFromWatchListUseCase(userRepository: r.resolve(UserRepository.self)!)
        }.inObjectScope(.transient)

        container.register(UpdateWatchListUsecase.self) { r in
            DefaultUpdateWatchListUsecase(
                userRepository: r.resolve(UserRepository.self)!,
                appData: r.resolve(AppDataManager.self)!
            )
        }.inObjectScope(.transient)
        
        container.register(FetchWatchListUsecase.self) { r in
            DefaultFetchWatchListUsecase(
                userRepository: r.resolve(UserRepository.self)!,
                appData: r.resolve(AppDataManager.self)!
            )
        }.inObjectScope(.transient)
        
        container.register(AddCommentUseCase.self) { r in
            DefaultAddCommentUseCase(
                moviesRepository: r.resolve(MoviesRepository.self)!,
                appData: r.resolve(AppDataManager.self)!
            )
        }.inObjectScope(.transient)
        
        container.register(SetWatchListIdsToLocalUseCase.self) { r in
            DefaultSetWatchListIdsToLocalUseCase(appData: r.resolve(AppDataManager.self)!)
        }.inObjectScope(.transient)
        
        container.register(AddToWatchListUseCase.self) { r in
            DefaultAddToWatchListUseCase(userRepository: r.resolve(UserRepository.self)!)
        }.inObjectScope(.transient)
        
        container.register(LoadAppDataUseCase.self) { r in
            DefaultLoadAppDataUseCase(appData: r.resolve(AppDataManager.self)!)
        }.inObjectScope(.transient)
        
        container.register(LogInUseCase.self) { r in
            DefaultLogInUseCase(
                authService: r.resolve(AuthService.self)!,
                appData: r.resolve(AppDataManager.self)!)
        }.inObjectScope(.transient)
    }
}
