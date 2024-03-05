import UIKit
import Kingfisher

class CastCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet private(set) weak var actorImageView: UIImageView!
    @IBOutlet private(set) weak var actorNameLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        actorImageView.layer.cornerRadius = 6
    }
    
    func updateDataOfCell(actorName: String, imageUrl: String){
        let imageUrl = URL(string: imageUrl)
        self.actorImageView.kf.setImage(with: imageUrl)
        self.actorNameLabel.text = actorName
    }
}
