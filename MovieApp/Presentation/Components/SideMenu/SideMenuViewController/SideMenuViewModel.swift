import Foundation
import RxSwift
import RxCocoa

class SideMenuViewMode : BaseViewModel {
    private lazy var getCurrentUserUseCase = AppDIContainer.resolve(GetCurrentUserUseCase.self)!
    lazy var currentUser = getCurrentUserUseCase.execute()
    lazy var logOutUseCae = AppDIContainer.resolve(LogOutUseCase.self)!


    struct Input {
        let reloadAppTrigger: Driver<Void>
        let reloadDataTrigger: Driver<Void>
        let logoutTrigger: Signal<Void>
    }
    
    struct Output {
        let loadingState: Driver<Bool>
        let reloadApp: Driver<Bool>
        let reloadData: Driver<Void>
        let currentUser: Driver<User?>
        let error: Driver<String>
    }
    
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let reloadAppRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = BehaviorRelay<String>(value: "")
    private let reloadUserDataAppRelay = BehaviorRelay<Bool>(value: false)
    private let currentUserRelay = BehaviorRelay<User?>(value: nil)
    
    func transform(input: Input) -> Output {
        listenLogOut(input: input)
        currentUser.bind(to: currentUserRelay).disposed(by: disposeBag)
        return Output(
            loadingState: loadingRelay.asDriverOnErrorJustComplete(),
            reloadApp: reloadAppRelay.asDriverOnErrorJustComplete(),
            reloadData: .just(()),
            currentUser: currentUserRelay.asDriverOnErrorJustComplete(),
            error: errorRelay.asDriverOnErrorJustComplete()
        )
    }
    
    func listenLogOut(input: Input) {
        input.logoutTrigger
            .flatMap { [weak self] _ -> Driver<Result<Any?, any Error>> in
                guard let self  = self else { return .empty()}
                return logOutUseCae.execute().asDriverOnErrorJustComplete()
            }
            .drive { [weak self] result in
                guard let self  = self else { return }
                switch result {
                case .success(_):
                    reloadAppRelay.accept(true)
                case .failure(let error):
                    errorRelay.accept(Utils.localizedDescription(for: error))
                }
            }
            .disposed(by: disposeBag)
    }
}
