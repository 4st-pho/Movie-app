import UIKit

class HorizontalMovieTableViewCell: UITableViewCell {
    // MARK: - Variables
    private let categoryCellNibName = String(describing: CategoryCollectionViewCell.self)
    var maxCategory = 6;
    var categories : [String] = [] {
        didSet {
            categoryColectionView.reloadData()
            updateConstraints()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet private(set) weak var categoryColectionView: UICollectionView!
    @IBOutlet private(set) weak var movieNameLabel: UILabel!
    @IBOutlet private(set) weak var durationLabel: UILabel!
    @IBOutlet private(set) weak var movieImageView: UIImageView!
    @IBOutlet private(set) weak var ratingLabel: UILabel!
    @IBOutlet private(set) weak var categoryColectionViewHeight: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    override func updateConstraints() {
        super.updateConstraints()
        self.categoryColectionViewHeight.constant = self.categoryColectionView.collectionViewLayout.collectionViewContentSize.height
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK: - UI Setup
    func setupUI() {
        self.movieImageView.layer.cornerRadius = 8
        self.setupCollectionView()
    }
    
    private func setupCollectionView() {
        categoryColectionView.dataSource = self
        categoryColectionView.delegate = self
        let layout = TagFlowLayout()
        categoryColectionView.collectionViewLayout = layout
        let categoryCellNib = UINib(nibName: categoryCellNibName, bundle: nil)
        categoryColectionView.register(categoryCellNib, forCellWithReuseIdentifier: categoryCellNibName)
    }
}

// MARK: - Popular Moview Collection View Data Source
extension HorizontalMovieTableViewCell : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count > maxCategory ?  maxCategory : categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellNibName, for: indexPath) as? CategoryCollectionViewCell
        else { return UICollectionViewCell()}
        cell.categoryLabel.text = categories[indexPath.row].uppercased()
        return cell
    }
}

// MARK: - Horizontal Movie Table View Delegate Flow Layout {
extension HorizontalMovieTableViewCell : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let title = categories[indexPath.row]
        let paddingHorizontal = 12.0
        let width = title.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 8, weight: .bold)]).width + paddingHorizontal * 2 + 12
        return CGSize(width: width, height: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}
