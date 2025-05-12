//
//  LoginViewModel.swift
//  MovieApp
//
//  Created by Rikkei on 12/05/2025.
//

import Foundation
import Combine
import RxSwift

class LoginViewModel: BaseViewModel, ObservableObject {
    // MARK: - Published Properties
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = "" {
        didSet {
            if oldValue == errorMessage {
                errorMessage += " "
            }
        }
    }
    
    // MARK: - Private Properties
    private let loginUseCase = AppDIContainer.resolve(LogInUseCase.self)!
    
    // MARK: - Public Methods
    
    func login() {
        guard !username.isEmpty && !password.isEmpty else {
            errorMessage = "Invalid input"
            return
        }
        
        isLoading = true
        
        convertToCombinePublisher(
            observable: loginUseCase.execute(requestValue: .init(emai: username, password: password))
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.isLoading = false
            if case .failure(let error) = completion {
                self?.errorMessage = Utils.localizedDescription(for: error)
            }
        } receiveValue: { [weak self] result in
            switch result {
            case .success(let data):
                AppConfiguration.setCurrentToken(data.token)
                AppDIContainer.resolve(AppDataManager.self)?.setCurrentUser(data.user)
                Utils.resetRootView()
            case .failure(let error):
                self?.errorMessage = Utils.localizedDescription(for: error)
            }
        }
        .store(in: &cancellables)
    }
}
