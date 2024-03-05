import Foundation

class SideMenuViewMode : BaseViewModel {
    private lazy var getCurrentUserUseCase: GetCurrentUserUseCase = DefaultGetCurrentUserUseCase()
    lazy var currentUser = getCurrentUserUseCase.execute()
    lazy var logOutUseCae : LogOutUseCase = DefaultLogOutUseCase()
    let reloadApp: Observable<Bool> = Observable(false)
    let reloadData: Observable<Bool> = Observable(false)
    let error: Observable<String> = Observable("")


    func load(showLoading: Bool = false) {}
    
    func reloadUserData() {
        currentUser = getCurrentUserUseCase.execute()
//        reloadApp.value = true
    }
    func logOut(){
        logOutUseCae.execute(){ [weak self] result in
            guard let self  = self else { return }
            switch result {
            case .success(_):
                reloadApp.value = true
            case .failure(let error):
                self.error.value = Utils.localizedDescription(for: error)
            }
        }
    }
}
