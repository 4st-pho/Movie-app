import Foundation

class LoginViewModel : BaseViewModel{
    let loginUseCase: LogInUseCase = DefaultLogInUseCase()
    var loadingState: Observable<Bool>  = Observable(false)
    var reloadApp: Observable<Bool>  = Observable(false)
    var error: Observable<String>  = Observable("")
    
    
    func load(showLoading: Bool = false) {
        
    }
    
    func LoginWithEmailAndPassword(email: String, password: String){
        loadingState.value = true
        loginUseCase.execute(
            requestValue: .init(emai: email, password: password)
        ){ [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                loadingState.value = false
                switch result {
                case .success(_):
                    self.reloadApp.value = true
                case .failure(let error):
                    self.error.value = Utils.localizedDescription(for: error)
                    
                }
                
            }
        }
    }
    
    
}
