import Foundation

protocol SetWatchListIdsToLocalUseCase {
    func execute(_ ids: [String])
}

final class DefaultSetWatchListIdsToLocalUseCase: SetWatchListIdsToLocalUseCase {
    private let appData: AppDataManager
    init(appData: AppDataManager = AppDataManager.shared) {
        self.appData = appData
    }

    func execute(_ ids: [String]) {
        appData.setWatchListIds(ids)
    }
}
