import Foundation

protocol GetCurrentUserUseCase {
    func execute() -> User?
}

final class DefaultGetCurrentUserUseCase: GetCurrentUserUseCase {
    private let appData: AppDataManager
    init(appData: AppDataManager) {
        self.appData = appData
    }

    func execute() -> User? {
        return appData.getCurrentUser()
    }
}
