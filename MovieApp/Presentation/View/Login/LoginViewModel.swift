import Foundation
import RxSwift
import RxCocoa

class LoginViewModel : BaseViewModel, ViewModelTransformable {
    struct Input {
        let email: Driver<String>
        let password: Driver<String>
        let loginTrigger: Driver<Void>
    }
    
    struct Output {
        let loadingState: Driver<Bool>
        let reloadApp: Signal<Void>
        let error: Driver<String>
    }
    
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let reloadAppRelay = PublishRelay<Void>()
    private let errorRelay = BehaviorRelay<String>(value: "")
    
    func transform(input: Input) -> Output {
        listenLoginWithEmailAndPassword(input: input)
        return Output(
            loadingState: loadingRelay.asDriverOnErrorJustComplete(),
            reloadApp: reloadAppRelay.asSignalOnErrorJustComplete(),
            error: errorRelay.asDriverOnErrorJustComplete()
        )
    }
    let loginUseCase = AppDIContainer.resolve(LogInUseCase.self)!
    
    func listenLoginWithEmailAndPassword(input: Input) {
        input.loginTrigger.withLatestFrom(Driver.combineLatest(input.email, input.password))
            .drive(onNext: { [weak self] email, password in
                guard let self  = self else { return }
                if email.isEmpty || password.isEmpty {
                    errorRelay.accept("Invalid input")
                    return
                }
                loginUseCase.execute(
                    requestValue: .init(emai: email, password: password)
                ).subscribe(onNext: { [weak self] result in
                    guard let self  = self else { return }
                    switch result {
                    case .success(let data):
                        AppConfiguration.setCurrentToken(data.token)
                        AppDIContainer.resolve(AppDataManager.self)?.setCurrentUser(data.user)
                        self.reloadAppRelay.accept(())
                    case .failure(let error):
                        self.errorRelay.accept(Utils.localizedDescription(for: error))
                    }
                }, onError: { [weak self] error in
                    guard let self  = self else { return }
                    self.errorRelay.accept(Utils.localizedDescription(for: error))
                }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
    }
}
