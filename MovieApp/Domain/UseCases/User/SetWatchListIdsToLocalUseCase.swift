import Foundation

protocol SetWatchListIdsToLocalUseCase {
    func execute(_ ids: [String])
}

final class DefaultSetWatchListIdsToLocalUseCase: SetWatchListIdsToLocalUseCase {
    private let appData: AppDataManager
    init(appData: AppDataManager) {
        self.appData = appData
    }
    
    func execute(_ ids: [String]) {
        appData.setWatchListIds(ids)
        
    }
}
