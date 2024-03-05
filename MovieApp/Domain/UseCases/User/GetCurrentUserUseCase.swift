import Foundation

protocol GetCurrentUserUseCase {
    func execute() -> User?
}

final class DefaultGetCurrentUserUseCase: GetCurrentUserUseCase {
    private let appData: AppDataManager
    init(appData: AppDataManager = AppDataManager.shared) {
        self.appData = appData
    }

    func execute() -> User? {
        return appData.getCurrentUser()
    }
}
