import UIKit

class LoginViewController: BaseViewController {
    // MARK: - Variables
    private let viewModel = LoginViewModel()
    
    // MARK: - Outlets
    @IBOutlet private (set) weak var emailTextField: UITextField!
    @IBOutlet private (set) weak var passwordTextField: UITextField!
    @IBOutlet private (set) weak var LoginButton: UIButton!
    
    // MARK: - UIComponents
    lazy private var showHidePasswordButton: UIButton = {
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
        self.setupNavigationBar()
        binding()
        setupUI()
    }
    
    // MARK: - Binding View model
    private func binding() {
        let input = LoginViewModel.Input(
            email: emailTextField.rx.text.orEmpty.asDriverOnErrorJustComplete(),
            password: passwordTextField.rx.text.orEmpty.asDriverOnErrorJustComplete(),
            loginTrigger: LoginButton.rx.tap.asDriverOnErrorJustComplete()
        )
        
        let output = viewModel.transform(input: input)
        
        output.loadingState.drive { [weak self] state in
            self?.updateLoadingState(state)
        }.disposed(by: disposeBag)
        
        output.error.drive { [weak self] error in
            self?.showError(error)
        }.disposed(by: disposeBag)
        
        output.reloadApp.emit{ _ in
            Utils.resetRootView()
        }.disposed(by: disposeBag)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        customOutlets()
    }
    
    private func customOutlets(){
        passwordTextField.rightViewMode = .always
        passwordTextField.rightView = showHidePasswordButton
        emailTextField.applyCustomStyle(style: .outline)
        passwordTextField.applyCustomStyle(style: .outline)
        LoginButton.applyCustomStyle(style: .primary)
    }
    
    // MARK: - Actions
    @IBAction func emailDidEndOnExit(_ sender: Any) {
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func passwordDidEndOnExit(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func loginTextTapped(_ sender: Any) {
        navigationController?.pushViewController(RegisterViewController(), animated: true)
    }
    
    
    // MARK: - Selectors
    @objc private func showHideButtonTapped(){
        let showHideState = !showHidePasswordButton.isSelected
        showHidePasswordButton.isSelected = showHideState
        passwordTextField.isSecureTextEntry = showHideState
    }
}
