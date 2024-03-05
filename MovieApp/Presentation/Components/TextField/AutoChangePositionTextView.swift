import UIKit

class AutoChangePositionTextView: UITextView {
    
    // MARK: - Properties
    
    private var originalFrame: CGRect?
    private var isKeyboardShown = false
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
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
        
        if isFirstResponder && !isKeyboardShown {
            originalFrame = self.frame
            moveTextView(up: true, distance: keyboardHeight)
            isKeyboardShown = true
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        if isKeyboardShown {
            moveTextView(up: false, distance: 0)
            isKeyboardShown = false
        }
    }
    
    private func moveTextView(up: Bool, distance: CGFloat) {
        let moveDuration = 0.3
        
        let movement: CGFloat = up ? -distance : 0
        
        UIView.animate(withDuration: moveDuration) {
            self.frame = self.originalFrame?.offsetBy(dx: 0, dy: movement) ?? self.frame
        }
    }
}

// MARK: - UITextViewDelegate

extension AutoChangePositionTextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Additional customizations when editing begins
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // Additional customizations when editing ends
    }
}
