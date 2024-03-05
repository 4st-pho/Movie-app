import UIKit

class VerticelMovieCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet private(set) weak var movieImageView: UIImageView!
    @IBOutlet private(set) weak var ratingLabel: UILabel!
    @IBOutlet private(set) weak var movieNameLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        movieImageView.layer.cornerRadius = 8
    }

}
