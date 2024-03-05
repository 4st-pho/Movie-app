import Foundation

class RegisterViewModel : BaseViewModel{
    lazy var registerUseCase: RegisterUseCase = DefaultRegisterUseCase()
    var loadingState: Observable<Bool>  = Observable(false)
    var error: Observable<String>  = Observable("")
    var successMessage: Observable<String>  = Observable("")
    
    func load(showLoading: Bool = false) {}
    
    func register(email: String, username: String, password: String){
        loadingState.value = true
        let requestValue = RegisterRequestValue(emai: email, password: password, username: username)
        registerUseCase.execute(requestValue: requestValue) { [weak self] result in
            guard let self  = self else { return }
            loadingState.value = false
            switch result {
            case .success(_):
                successMessage.value = "Registered successfully"
            case .failure(let error):
                print(Utils.localizedDescription(for: error))
                self.error.value = Utils.localizedDescription(for: error)
            }
            
        }
    }
    
}
