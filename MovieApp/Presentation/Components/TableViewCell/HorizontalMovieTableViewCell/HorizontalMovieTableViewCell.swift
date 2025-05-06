import UIKit
import RxSwift
import RxCocoa

class HorizontalMovieTableViewCell: UITableViewCell {
    // MARK: - Variables
    let disposeBag = DisposeBag()
    var maxCategory = 6;
    var categories : [String] = [] {
        didSet {
            categoriesRelay.accept(categories)
        }
    }
    private let categoriesRelay = BehaviorRelay<[String]>(value: [])
    
    // MARK: - Outlets
    @IBOutlet private(set) weak var movieNameLabel: UILabel!
    @IBOutlet private(set) weak var durationLabel: UILabel!
    @IBOutlet private(set) weak var movieImageView: UIImageView!
    @IBOutlet private(set) weak var ratingLabel: UILabel!
    @IBOutlet private(set) weak var categoryColectionViewHeight: NSLayoutConstraint!
    @IBOutlet private(set) weak var categoryColectionView: UICollectionView! {
        didSet {
            categoryColectionView.letIt {
                $0.delegate = self
                let layout = TagFlowLayout()
                $0.collectionViewLayout = layout
                $0.register(nibType: CategoryCollectionViewCell.self)
            }
        }
    }
    
    // MARK: - Lifecycle
    
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
        categoryColectionView.rx.bindContentHeight(to: categoryColectionViewHeight).disposed(by: disposeBag)
        categoriesRelay
            .asDriver()
            .drive(categoryColectionView.rx.items) { collectionView, row, element in
                let indexPath = IndexPath(row: row, section: 0)
                let cell = collectionView.dequeueReusableCell(with: CategoryCollectionViewCell.self, for: indexPath)
                cell.categoryLabel.text = self.categories[indexPath.row].uppercased()
                return cell
            }
            .disposed(by: disposeBag)
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
