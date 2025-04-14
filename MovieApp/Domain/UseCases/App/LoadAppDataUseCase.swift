import Foundation

protocol LoadAppDataUseCase {
    func execute()
}

final class DefaultLoadAppDataUseCase: LoadAppDataUseCase {
    private let appData: AppDataManager
    init(appData: AppDataManager) {
        self.appData = appData
    }
    
    func execute() {
        appData.initialize()
    }
    
}
