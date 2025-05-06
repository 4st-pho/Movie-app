import Foundation
import RxSwift
import RxCocoa
class UserProfileViewModel : BaseViewModel {
    private lazy var getCurrentUserUseCase = AppDIContainer.resolve(GetCurrentUserUseCase.self)!
    private lazy var updateUserUseCase = AppDIContainer.resolve(UpdateUserUseCase.self)!
    
    struct Input {
        let username: Driver<String?>
        let birthdate: Driver<String?>
        let file: Driver<Data?>
        let updatePrifileTrigger: Driver<Void>
        let updateWithImage: Driver<Bool>
    }
    
    struct Output {
        let loadingState: Driver<Bool>
        let error: Driver<String>
        let message: Driver<String>
        let currentUser: Driver<User?>
    }
    
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = BehaviorRelay<String>(value: "")
    private let messageRelay = BehaviorRelay<String>(value: "")
    private let updateWithImage = BehaviorRelay<Bool>(value: false)
    
    func transform(input: Input) -> Output {
        listenUpdateUser(input: input)
        input.updateWithImage.drive(self.updateWithImage).disposed(by: disposeBag)
        return Output(
            loadingState: loadingRelay.asDriverOnErrorJustComplete(),
            error: errorRelay.asDriverOnErrorJustComplete(),
            message: messageRelay.asDriverOnErrorJustComplete(),
            currentUser: getCurrentUserUseCase.execute().asDriverOnErrorJustComplete()
        )
    }
    
    
    private func listenUpdateUser(input: Input) {
        input.updatePrifileTrigger.withLatestFrom(Driver.combineLatest(input.username, input.birthdate, input.file))
            .flatMap { [weak self] (username, birthdate, file) -> Driver<Result<User, any Error>> in
                guard let self  = self else { return .empty()}
                loadingRelay.accept(true)
                let image = updateWithImage.value ? file : nil
                var data :  [String: Any] = [String: Any]()
                if let username = username, !username.isEmpty {
                    data["username"] = username
                }
                if let birthdate = birthdate, !birthdate.isEmpty {
                    data["birthdate"] = birthdate
                }
                print(data)
                return updateUserUseCase.execute(data: data, file: image).asDriverOnErrorJustComplete()
            }.drive(onNext: { [weak self] result in
                guard let self = self else { return }
                loadingRelay.accept(false)
                updateWithImage.accept(false)
                switch result {
                case .success(_):
                    messageRelay.accept("Update successfully")
                case .failure(let error):
                    errorRelay.accept(Utils.localizedDescription(for: error))
                    
                }
            }).disposed(by: disposeBag)
        
    }
    
}
