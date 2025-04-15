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
        let reloadApp: Driver<Bool>
        let error: Driver<String>
    }
    
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let reloadAppRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = BehaviorRelay<String>(value: "")
    
    func transform(input: Input) -> Output {
        input.loginTrigger
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.loginWithEmailAndPassword(input: input)
                
            }).disposed(by: disposeBag)
        return Output(
            loadingState: loadingRelay.asDriverOnErrorJustComplete(),
            reloadApp: reloadAppRelay.asDriverOnErrorJustComplete(),
            error: errorRelay.asDriverOnErrorJustComplete()
        )
    }
    let loginUseCase = AppDIContainer.resolve(LogInUseCase.self)!
    
    func loginWithEmailAndPassword(input: Input) {
        input.loginTrigger.withLatestFrom(Driver.combineLatest(input.email, input.password))
            .drive(onNext: { [weak self] email, password in
                guard let self  = self else { return }
                loginUseCase.execute(
                    requestValue: .init(emai: email, password: password)
                ).subscribe(onNext: { [weak self] result in
                    guard let self  = self else { return }
                    switch result {
                    case .success(let data):
                        AppConfiguration.setCurrentToken(data.token)
                        AppDIContainer.resolve(AppDataManager.self)?.setCurrentUser(data.user)
                        self.reloadAppRelay.accept(true)
                    case .failure(let error):
                        self.errorRelay.accept(error.localizedDescription)
                    }
                }, onError: { [weak self] error in
                    guard let self  = self else { return }
                    self.errorRelay.accept(error.localizedDescription)
                }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
    }
}
