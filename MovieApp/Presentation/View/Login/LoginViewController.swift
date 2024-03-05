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
    private func binding(){
        viewModel.error.observe(on: self){[weak self] in self?.showError($0)}
        viewModel.loadingState.observe(on: self){[weak self] in self?.updateLoadingState($0)}
        viewModel.reloadApp.observe(on: self) { hasReload in
            if hasReload{
                Utils.resetRootView()
            }
        }
        viewModel.load()
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
    
    // MARK: - Functions
    private func loginWithEmailAndPassword(){
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        if(email.isEmpty || password.isEmpty){
            showError("Invalid input")
            return
        }
        viewModel.LoginWithEmailAndPassword(email: email, password: password)
    }
    
    // MARK: - Actions
    @IBAction func emailDidEndOnExit(_ sender: Any) {
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func passwordDidEndOnExit(_ sender: Any) {
        loginWithEmailAndPassword()
        view.endEditing(true)
    }
    
    @IBAction func loginTextTapped(_ sender: Any) {
        navigationController?.pushViewController(RegisterViewController(), animated: true)
    }
    
    @IBAction func signInButtonTouchUpInside(_ sender: Any) {
        loginWithEmailAndPassword()
        view.endEditing(true)
    }
    
    // MARK: - Selectors
    @objc private func showHideButtonTapped(){
        let showHideState = !showHidePasswordButton.isSelected
        showHidePasswordButton.isSelected = showHideState
        passwordTextField.isSecureTextEntry = showHideState
    }
}
