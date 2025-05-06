import Foundation
import RxSwift

protocol UpdateUserUseCase {
    func execute(
        data: [String: Any],
        file: Data?
    ) -> Observable<Result<User, Error>>
}

final class DefaultUpdateUserUseCase: UpdateUserUseCase {
    func execute(data: [String : Any], file: Data?) -> Observable<Result<User, Error>> {
        let uid = appData.getCurrentUser()?.id ?? ""
        return Observable.create { signal in
            self.userRepository.updateUserWithImage(id: uid, data: data, file: file){ [weak self] result in
                guard let self  = self else { return }
                switch result {
                case .success(let data):
                    appData.setCurrentUser(data)
                case .failure(let error): break
                }
                signal.onNext(result)
                signal.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    let appData: AppDataManager
    private let userRepository: UserRepository
    init(userRepository: UserRepository, appData: AppDataManager) {
        self.userRepository = userRepository
        self.appData = appData
    }
}
