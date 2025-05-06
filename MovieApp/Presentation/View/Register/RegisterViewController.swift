import UIKit
import RxSwift
import RxCocoa


class RegisterViewController: BaseViewController {
    // MARK: - Variables
    private let viewModel = RegisterViewModel()
    
    // MARK: - Outlets
    @IBOutlet private (set) weak var emailTextField: UITextField!
    @IBOutlet private (set) weak var passwordTextField: UITextField!
    @IBOutlet private (set) weak var confirmPasswordTextField: UITextField!
    @IBOutlet private (set) weak var usernameTextField: UITextField!
    @IBOutlet private (set) weak var loginButton: UIButton!
    
    // MARK: - UI Components
    private let showHidePasswordButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        button.setBackgroundImage(UIImage(systemName: "eye.fill"), for: .selected)
        button.addTarget(nil, action: #selector(showHideButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let showHideConfirmPasswordButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        button.setBackgroundImage(UIImage(systemName: "eye.fill"), for: .selected)
        button.addTarget(nil, action: #selector(showHideButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        binding()
        setupUI()
        
    }
    
    // MARK: - Binding view model
    private func binding(){
        let registerData = Driver.combineLatest(
            usernameTextField.rx.text.orEmpty.asDriverOnErrorJustComplete(),
            emailTextField.rx.text.orEmpty.asDriverOnErrorJustComplete(),
            passwordTextField.rx.text.orEmpty.asDriverOnErrorJustComplete(),
            confirmPasswordTextField.rx.text.orEmpty.asDriverOnErrorJustComplete()
        ) {(username: $0, email: $1, password: $2, comfirmPassword: $3)}
        
        let input = RegisterViewModel.Input(
            registerData: registerData,
            registerTrigger: loginButton.rx.tap.asDriverOnErrorJustComplete())
        
        let output = viewModel.transform(input: input)
        output.loadingState.drive { [weak self] state in
            self?.updateLoadingState(state)
        }.disposed(by: disposeBag)
        
        output.error.drive { [weak self] error in
            self?.showError(error)
        }.disposed(by: disposeBag)
        
        output.successMessage.drive { [weak self] value in
            self?.handleRegistrationSuccess(value)
        }.disposed(by: disposeBag)
    }
    
    private func handleRegistrationSuccess(_ message: String) {
        guard !message.isEmpty else { return }
        showAlert(title: "Success", message: message) {
        } alertActionHanler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        customOutlets()
        
    }
    
    private func customOutlets(){
        passwordTextField.rightViewMode = .always
        confirmPasswordTextField.rightViewMode = .always
        passwordTextField.rightView = showHidePasswordButton
        confirmPasswordTextField.rightView = showHideConfirmPasswordButton
        emailTextField.applyCustomStyle(style: .outline)
        passwordTextField.applyCustomStyle(style: .outline)
        confirmPasswordTextField.applyCustomStyle(style: .outline)
        usernameTextField.applyCustomStyle(style: .outline)
        loginButton.applyCustomStyle(style: .primary)
    }
    
    // MARK: - Functions
    
    // MARK: - Actions
    @IBAction func emailDidEndOnExit(_ sender: Any) {
        usernameTextField.becomeFirstResponder()
    }
    @IBAction func usernameDidEndOnExit(_ sender: Any) {
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func passwordDidEndOnExit(_ sender: Any) {
        confirmPasswordTextField.becomeFirstResponder()
    }
    
    @IBAction func confirmPasswordDidEndOnExit(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func loginButtonTouchUpInside(_ sender: Any) {
        view.endEditing(true)
    }
    
    // MARK: - Selectors
    @objc private func showHideButtonTapped(){
        let showHideState = !showHidePasswordButton.isSelected
        showHidePasswordButton.isSelected = showHideState
        showHideConfirmPasswordButton.isSelected = showHideState
        passwordTextField.isSecureTextEntry = showHideState
        confirmPasswordTextField.isSecureTextEntry = showHideState
    }
}

