import Foundation

protocol GetLocalWatchListIdsUseCase {
    func execute() -> [String]
}

final class DefaultGetLocalWatchListIdsUseCase: GetLocalWatchListIdsUseCase {
    private let appData: AppDataManager
    init(appData: AppDataManager) {
        self.appData = appData
    }

    func execute() -> [String] {
        return appData.getsWatchListIds()
    }
}
