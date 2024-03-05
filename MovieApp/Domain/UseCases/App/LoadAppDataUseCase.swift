import Foundation

protocol LoadAppDataUseCase {
    func execute()
}

final class DefaultLoadAppDataUseCase: LoadAppDataUseCase {
    private let appData: AppDataManager
    init(appData: AppDataManager = AppDataManager.shared) {
        self.appData = appData
    }
    
    func execute() {
        appData.initialize()
    }
    
}
