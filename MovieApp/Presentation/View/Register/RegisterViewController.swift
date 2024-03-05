import UIKit

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
        viewModel.error.observe(on: self){[weak self] in self?.showError($0)}
        viewModel.loadingState.observe(on: self){[weak self] in self?.updateLoadingState($0)}
        viewModel.successMessage.observe(on: self){[weak self] in self?.handleRegistrationSuccess($0)}
        viewModel.load()
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
    private func Register(){
        let email = (emailTextField.text ?? "").trim()
        let username = (usernameTextField.text ?? "").trim()
        let password = (passwordTextField.text ?? "").trim()
        let confirmPassword = (confirmPasswordTextField.text ?? "").trim()
        let isValidInput = !email.isEmpty && !password.isEmpty && !username.isEmpty && !confirmPassword.isEmpty
        
        if !isValidInput {
            showError("Invalid input")
            return
        }
        if !(passwordTextField.text == confirmPasswordTextField.text) {
            showError("Password not match confirm password")
            return
        }
        
        viewModel.register(email: email, username: username, password: password)
        
    }
    
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
        Register()
        view.endEditing(true)
    }
    
    @IBAction func loginButtonTouchUpInside(_ sender: Any) {
        Register()
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

