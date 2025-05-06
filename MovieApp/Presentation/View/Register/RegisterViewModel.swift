import Foundation
import RxSwift
import RxCocoa

typealias RegisterData = (username: String, email: String, password: String, comfirmPassword: String)

class RegisterViewModel : BaseViewModel{
    lazy var registerUseCase = AppDIContainer.resolve(RegisterUseCase.self)!
    
    struct Input {
        let registerData: Driver<RegisterData>
        let registerTrigger: Driver<Void>
    }
    
    struct Output {
        let loadingState: Driver<Bool>
        let reloadApp: Driver<Bool>
        let error: Driver<String>
        let successMessage: Driver<String>
    }
    
    
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let reloadAppRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = BehaviorRelay<String>(value: "")
    private let successMessageRelay = BehaviorRelay<String>(value: "")
    
    func transform(input: Input) -> Output {
        input.registerTrigger.withLatestFrom(input.registerData)
            .drive(onNext: { [weak self] registerData in
                guard let self = self else { return }
                self.validateAndRegister(input: input, registerData: registerData)
                
            }).disposed(by: disposeBag)
        
        return Output(
            loadingState: loadingRelay.asDriverOnErrorJustComplete(),
            reloadApp: reloadAppRelay.asDriverOnErrorJustComplete(),
            error: errorRelay.asDriverOnErrorJustComplete(),
            successMessage: successMessageRelay.asDriverOnErrorJustComplete()
        )
    }
    
    func validateAndRegister(input: Input, registerData: RegisterData) {
        if let errorMessage = errorValidateRegisterData(registerData: registerData) {
            self.errorRelay.accept(errorMessage)
            return
        }
        loadingRelay.accept(true)
        let requestValue = RegisterRequestValue(
            emai: registerData.email.trim(),
            password: registerData.password.trim(),
            username: registerData.username.trim()
        )
        registerUseCase.execute(requestValue: requestValue).subscribe { [weak self] result in
            guard let self  = self else { return }
            loadingRelay.accept(false)
            switch result {
            case .success(_):
                successMessageRelay.accept("Registered successfully")
            case .failure(let error):
                print(Utils.localizedDescription(for: error))
                errorRelay.accept(Utils.localizedDescription(for: error))
            }
        }.disposed(by: disposeBag)
    }
    
    func errorValidateRegisterData(registerData: RegisterData) -> String? {
        let email = (registerData.email ).trim()
        let username = (registerData.username ).trim()
        let password = (registerData.password ).trim()
        let confirmPassword = (registerData.comfirmPassword ).trim()
        let isValidInput = !email.isEmpty && !password.isEmpty && !username.isEmpty && !confirmPassword.isEmpty
        
        if !isValidInput {
            return "Invalid input"
        }
        if !(registerData.password == registerData.comfirmPassword) {
            return "Password not match confirm password"
        }
        return nil
    }
}
