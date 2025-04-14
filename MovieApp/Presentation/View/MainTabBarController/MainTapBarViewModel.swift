import Foundation

class MainTapBarViewModel: BaseViewModel {
    lazy var loadAppDataUseCase = AppDIContainer.resolve(LoadAppDataUseCase.self)!
    
    func load(showLoading: Bool = false) {
        DispatchQueue.global().async { [weak self] in
            self?.loadAppDataUseCase.execute()
        }
    }
    
    
}
