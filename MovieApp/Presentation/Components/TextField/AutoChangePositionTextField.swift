import UIKit

class AutoChangePositionTextField: UITextField {
    
    // MARK: - Properties
    
    private var originalFrame: CGRect?
    private var isKeyboardShown = false
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        delegate = self
        addKeyboardObservers()
    }
    
    // MARK: - Keyboard Handling
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        if isEditing && !isKeyboardShown {
            originalFrame = self.frame
            moveTextField(up: true, distance: keyboardHeight)
            isKeyboardShown = true
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        if isKeyboardShown {
            moveTextField(up: false, distance: 0)
            isKeyboardShown = false
        }
    }
    
    private func moveTextField(up: Bool, distance: CGFloat) {
        let moveDuration = 0.3
        
        let movement: CGFloat = up ? -distance : 0
        
        UIView.animate(withDuration: moveDuration) {
            self.frame = self.originalFrame?.offsetBy(dx: 0, dy: movement) ?? self.frame
        }
    }
}

// MARK: - UITextFieldDelegate

extension AutoChangePositionTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Additional customizations when editing begins
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Additional customizations when editing ends
    }
}
