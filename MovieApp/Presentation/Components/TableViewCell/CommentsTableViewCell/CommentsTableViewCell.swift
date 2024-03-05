import UIKit

class CommentsTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet private(set) weak var commentLabel: UILabel!
    @IBOutlet private(set) weak var usernameLabel: UILabel!
    @IBOutlet private(set) weak var avatarImageView: UIImageView!
    @IBOutlet private(set) weak var avatarImageHeight: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        customOutlets()
    }
    
    private func customOutlets() {
        avatarImageView.layer.cornerRadius = avatarImageHeight.constant / 2
    }
    
}
