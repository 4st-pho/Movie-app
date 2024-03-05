import UIKit

protocol MovieSectionHeaderDelegate: AnyObject {
    func didSelectSeeMoreButton(title: String)
}

class MovieSectionHeader: UITableViewHeaderFooterView {
    weak var delegate: MovieSectionHeaderDelegate?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seeMoreButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    
    private func setupUI(){
        seeMoreButton.applyCustomStyle(style: .outline)
    }
    
    @IBAction func seeMoreTouchUpInside(_ sender: Any) {
        delegate?.didSelectSeeMoreButton(title: titleLabel.text ?? "")
    }
}
