import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Variables
    @IBOutlet private(set) weak var categoryLabel: UILabel!
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        self.layer.cornerRadius = 8
        self.backgroundColor = .appLightPurpleAccent
    }

}
