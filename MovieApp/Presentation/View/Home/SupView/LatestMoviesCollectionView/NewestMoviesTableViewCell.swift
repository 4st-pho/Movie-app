import UIKit

protocol NewestMoviesTableViewCellDelegate: AnyObject {
    func didSelectCollectionCell(_ tableViewCell: NewestMoviesTableViewCell, movie: Movie)
}

class NewestMoviesTableViewCell: UITableViewCell {
    // MARK: - Outlets
    weak var delegate: NewestMoviesTableViewCellDelegate?
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newestMovieCollectionViewHeight: NSLayoutConstraint!
    
    // MARK: - Variables
    var movies: [Movie] = []
    private let cellNibName = String(describing: VerticelMovieCollectionViewCell.self)
    
    // MARK: - Lifecycle
    override func updateConstraints() {
        super.updateConstraints()
        self.newestMovieCollectionViewHeight.constant = self.collectionView.collectionViewLayout.collectionViewContentSize.height
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI(){
        collectionView.delegate = self
        collectionView.dataSource  = self
        let cellNib = UINib(nibName: cellNibName, bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: cellNibName)
    }
}


// MARK: - Delegate
extension NewestMoviesTableViewCell : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectCollectionCell(self, movie: movies[indexPath.row])
    }
    
}

// MARK: - Datasource
extension NewestMoviesTableViewCell : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellNibName, for: indexPath) as? VerticelMovieCollectionViewCell
        else { return UICollectionViewCell()}
        
        let movie = movies[indexPath.row]
        let imageUrl = URL(string: movie.imageUrl)
        cell.movieImageView.kf.setImage(with: imageUrl)
        cell.movieNameLabel.text = movie.name
        cell.ratingLabel.text = movie.rating
        return cell
    }
}

extension NewestMoviesTableViewCell : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 143, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: Constant.edgePadding, bottom: 0, right: Constant.edgePadding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constant.edgePadding;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constant.edgePadding
    }
}
