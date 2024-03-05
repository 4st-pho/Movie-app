import UIKit

extension UIButton{
    
    enum CustomStyleType {
        case defaultStyle, outline, primary, float
    }
    
    func applyCustomStyle(style: CustomStyleType) {
        switch style {
        case .outline:
            self.configuration?.attributedTitle?.foregroundColor = .appGray
            self.configuration?.attributedTitle?.font =  .systemFont(ofSize: 10 , weight: .medium)
            self.layer.cornerRadius = 10
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor.appLighGray.cgColor
        case .primary:
            self.configuration?.attributedTitle?.font =  .systemFont(ofSize: 16 , weight: .medium)
            self.layer.cornerRadius = 20
            self.clipsToBounds = true
        case .float:
            self.backgroundColor = .appFloatButtonColor
            self.imageView?.tintColor = .systemBackground
            self.layer.cornerRadius = frame.width / 2
            self.layer.masksToBounds = false
            self.layer.shadowColor = UIColor.appFloatButtonColor.cgColor
            self.layer.shadowOpacity = 0.5
            self.layer.shadowOffset = CGSize(width: 0, height: 4)
            self.layer.shadowRadius = 8
            
        case CustomStyleType.defaultStyle:
            return
        }
    }
}
