import UIKit

class UnderlineInputBorderTextField: UITextField {
    let focusColor : UIColor = .appUnderlineInputColor
    let unfocusColor : UIColor = .appUnderlineInputUnfocusColor
    let underline = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextField()
    }
    
    private func setupTextField() {
        self.borderStyle = .none
        self.tintColor = focusColor
        self.addSubview(underline)
        
        underline.translatesAutoresizingMaskIntoConstraints = false
        underline.backgroundColor = unfocusColor
        NSLayoutConstraint.activate([
            underline.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            underline.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            underline.topAnchor.constraint(equalTo: self.bottomAnchor),
            underline.heightAnchor.constraint(equalToConstant: 1)
        ])
        self.delegate = self
    }
}

extension UnderlineInputBorderTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        underline.backgroundColor = focusColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        underline.backgroundColor = unfocusColor
    }
}




