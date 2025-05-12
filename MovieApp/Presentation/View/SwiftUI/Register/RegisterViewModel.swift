//
//  RegisterViewModel.swift
//  MovieApp
//
//  Created by Rikkei on 12/05/2025.
//

import Foundation

class RegisterViewModel: BaseViewModel, ObservableObject {
    // MARK: - Private Properties
    let registerUseCase = AppDIContainer.resolve(RegisterUseCase.self)!
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var successMessage: String = ""
    @Published var errorMessage: String = "" {
        didSet {
            if oldValue == errorMessage {
                errorMessage += " "
            }
        }
    }
    
    func validateAndRegister() {
        if let errorMessage = errorValidateRegisterData() {
            self.errorMessage = errorMessage
            return
        }
        self.isLoading = true
        let requestValue = RegisterRequestValue(
            emai: email.trim(),
            password: password.trim(),
            username: username.trim()
        )
        
        convertToCombinePublisher(observable: registerUseCase.execute(requestValue: requestValue))
            .sink { [weak self] result in
                guard let self  = self else { return }
                switch result{
                case .success(_):
                    successMessage = "Registered successfully"
                case .failure(let error):
                    print(Utils.localizedDescription(for: error))
                    errorMessage = Utils.localizedDescription(for: error)
                }
                isLoading = false
            }.store(in: &cancellables)
    }
    
    private func errorValidateRegisterData() -> String? {
        let email = email.trim()
        let username = username.trim()
        let password = password.trim()
        let confirmPassword = confirmPassword.trim()
        let isValidInput = !email.isEmpty && !password.isEmpty && !username.isEmpty && !confirmPassword.isEmpty
        
        if !isValidInput {
            return "Invalid input"
        }
        if !(password == confirmPassword) {
            return "Password not match confirm password"
        }
        return nil
    }
    
}
