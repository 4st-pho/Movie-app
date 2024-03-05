import Foundation

class UserProfileViewModel : BaseViewModel {
    private lazy var getCurrentUserUseCase: GetCurrentUserUseCase = DefaultGetCurrentUserUseCase()
    private lazy var updateUserUseCase: UpdateUserUseCase = DefaultUpdateUserUseCase()
    lazy var currentUser = getCurrentUserUseCase.execute()
    
    var loadingState: Observable<Bool>  = Observable(false)
    var message: Observable<String>  = Observable("")
    let error: Observable<String> = Observable("")
    func load(showLoading: Bool = false) {}
    var updateWithImage = false
    
    
    func updateUser(username: String?, birthdate: String?, file: Data?){
        loadingState.value = true
        let image = updateWithImage ? file : nil
        var data :  [String: Any] = [String: Any]()
        if let username = username, !username.isEmpty {
            data["username"] = username
        }
        if let birthdate = birthdate, !birthdate.isEmpty {
            data["birthdate"] = birthdate
        }
        print(data)
        updateUserUseCase.execute(data: data, file: image){ [weak self] result in
            guard let self = self else { return }
            loadingState.value = false
            updateWithImage = false
            switch result {
            case .success(_):
                message.value = "Update successfully"
            case .failure(let error):
                self.error.value = Utils.localizedDescription(for: error)
                
            }
        }
    }
    
}
