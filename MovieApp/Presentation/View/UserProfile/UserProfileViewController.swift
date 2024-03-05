import UIKit
import Kingfisher

class UserProfileViewController: BaseViewController, UINavigationControllerDelegate {
    // MARK: - Variables
    private let viewModel = UserProfileViewModel()
    let dateFormatter : DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter
    }()
    
    // MARK: - Outlets
    @IBOutlet private(set) weak var changePhotoLabel: UILabel!
    @IBOutlet private(set) weak var usernameTextField: UnderlineInputBorderTextField!
    @IBOutlet private(set) weak var birthdateTextField: UnderlineInputBorderTextField!
    @IBOutlet private(set) weak var emailTextField: UnderlineInputBorderTextField!
    @IBOutlet private(set) weak var floatButton: UIButton!
    @IBOutlet private(set) weak var avatarImageView: UIImageView!
    
    // MARK: - UI Components
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        if let maximumDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) {
            datePicker.maximumDate = maximumDate
        }
        if let minimumDate = Calendar.current.date(byAdding: .year, value: -130, to: Date()) {
            datePicker.minimumDate = minimumDate
        }
        return datePicker
    }()
    
    lazy var imagePicker : UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        return imagePicker
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindingViewModel()
    }
    
    // MARK: - Binding View Model
    private func bindingViewModel(){
        viewModel.loadingState.observe(on: self) { [weak self] in self?.updateLoadingState($0) }
        viewModel.error.observe(on: self) { [weak self] in self?.showError($0) }
        viewModel.message.observe(on: self) { [weak self] in self?.showMessage($0,title: "Message")}
        viewModel.load()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        customOutlets()
    }
    
    private func customOutlets() {
        let currentUser = viewModel.currentUser
        disableEditing()
        let imageUrl = URL(string: currentUser?.avatar ?? "")
        avatarImageView.kf.setImage(with: imageUrl)
        birthdateTextField.inputView = datePicker
        emailTextField.text = currentUser?.email
        usernameTextField.text = currentUser?.username
        if let birthdate = currentUser?.birthdate {
            birthdateTextField.text = dateFormatter.string(from: birthdate)
        }
        floatButton.applyCustomStyle(style: .float)
        
    }
    
    private func disableEditing() {
        emailTextField.isEnabled = false
        usernameTextField.isEnabled = false
        birthdateTextField.isEnabled = false
        changePhotoLabel.isUserInteractionEnabled = false
        changePhotoLabel.textColor = .appUnderlineInputUnfocusColor
        
    }
    
    private func enableEditing() {
        usernameTextField.isEnabled = true
        birthdateTextField.isEnabled = true
        changePhotoLabel.isUserInteractionEnabled = true
        usernameTextField.becomeFirstResponder()
        changePhotoLabel.textColor = .appUnderlineInputColor
    }
    
    // MARK: - Functions
    func updateUser(){
        let file = avatarImageView.image?.jpegData(compressionQuality: 0.8)
        let username = usernameTextField.text
        let birthdate = birthdateTextField.text
        viewModel.updateUser(username: username, birthdate: birthdate, file: file)
    }
    
    // MARK: - Actions
    @IBAction func usernameDidEndOnExit(_ sender: Any) {
        birthdateTextField.becomeFirstResponder()
    }
    
    @IBAction func floatButtonTouchUpInside(_ sender: Any) {
        if floatButton.isSelected {
            floatButton.isSelected.toggle()
            disableEditing()
            updateUser()
        } else {
            enableEditing()
            floatButton.isSelected.toggle()
        }
    }
    
    @IBAction func changeImageLabelTaped(_ sender: Any) {
        present(imagePicker, animated: true)
    }
    
    // MARK: - Selectors
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        birthdateTextField.text = dateFormatter.string(from: sender.date)
    }
}

extension UserProfileViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return}
        avatarImageView.image = image
        viewModel.updateWithImage = true
        dismiss(animated: true)
    }
}
