import UIKit

protocol LoggedInMiddlewareViewDelegate : AnyObject{
    func didTapLoginButton()
}

class LoggedInMiddlewareView: UIView {
    // MARK: - Outlets
    @IBOutlet weak var signInButton: UIButton!
    
    // MARK: - Variables
    weak var delegate: LoggedInMiddlewareViewDelegate?
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        signInButton.applyCustomStyle(style: .primary)
    }
    
    // MARK: - Actions
    @IBAction func signInTouchUpInside(_ sender: Any) {
        self.delegate?.didTapLoginButton()
    }
}
