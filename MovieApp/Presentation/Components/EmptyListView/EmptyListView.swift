import UIKit

class EmptyListView: UIView {
    
    // MARK: - Variables
    @IBOutlet private(set) weak var titlelabel: UILabel!
    @IBOutlet private(set) weak var imageView: UIImageView!
    
    @IBOutlet weak var subtitleLabel: UILabel!
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
