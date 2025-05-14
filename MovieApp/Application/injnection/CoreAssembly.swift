//
//  CoreAssembly.swift
//  MovieApp
//
//  Created by Rikkei on 14/04/2025.
//

import Foundation
import Swinject

final class CoreAssembly: Assembly {
    func assemble(container: Swinject.Container) {
        container.register(APIClient.self) { _ in
            APIClient()
        }.inObjectScope(.container)
        
        container.register(AppDataManager.self) { _ in
            AppDataManager()
        }.inObjectScope(.container)
        
        container.register(AppTheme.self) { _ in
            AppTheme()
        }.inObjectScope(.container)
        
        container.register(UserStorage.self) { _ in
            UserStorage()
        }.inObjectScope(.container)
        
        container.register(MoviesStorage.self) { _ in
            MoviesStorage()
        }.inObjectScope(.container)
        
        container.register(MoviesRepository.self) { r in
            return DefaultMovieRepository(apiClient: r.resolve(APIClient.self)!)
        }.inObjectScope(.container)
        
        container.register(UserRepository.self) { r in
            return DefaultUserRepository(
                apiClient: r.resolve(APIClient.self)!,
                cache: r.resolve(UserStorage.self)!,
                movieCache: r.resolve(MoviesStorage.self)!
            )
        }.inObjectScope(.container)
        
        container.register(AuthService.self) { r in
            return DefaultAuthService(
                apiClient: r.resolve(APIClient.self)!,
                cache: r.resolve(UserStorage.self)!
            )
        }.inObjectScope(.container)
    }
}
