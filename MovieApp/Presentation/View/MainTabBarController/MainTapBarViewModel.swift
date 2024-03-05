import Foundation

class MainTapBarViewModel: BaseViewModel {
    lazy var loadAppDataUseCase: LoadAppDataUseCase = DefaultLoadAppDataUseCase()
    
    func load(showLoading: Bool = false) {
        DispatchQueue.global().async { [weak self] in
            self?.loadAppDataUseCase.execute()
        }
    }
    
    
}
