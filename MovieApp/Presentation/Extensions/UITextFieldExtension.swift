import UIKit

extension UITextField{
    
    enum CustomStyleType {
        case defaultStyle, outline, underlineInputBorder
    }
    
    func applyCustomStyle(style: CustomStyleType) {
        switch style {
        case .outline:
            self.layer.cornerRadius = 6
            self.layer.borderColor = UIColor.appOutlineBorder.cgColor
            self.layer.borderWidth = 1
            self.backgroundColor = .appBackgroudTextField
            self.heightAnchor.constraint(equalToConstant: 46).isActive = true
        case .underlineInputBorder:
            let border = CALayer()
            let width = 2.0
            border.borderColor = UIColor.appLightPink.cgColor
            border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: self.frame.size.height)
            border.borderWidth = width
            self.borderStyle = .none
            self.tintColor = .appLightPink
            self.layer.addSublayer(border)
            self.layer.masksToBounds = true
            
        case .defaultStyle:
            return
        }
    }
}
