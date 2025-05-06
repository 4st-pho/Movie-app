import UIKit
import RxSwift
import RxCocoa

class CastViewController: BaseViewController {
    // MARK: - Variables
    var cast: [Actor]! {
        didSet {
            castRelay.accept(cast)
        }
    }
    private let castRelay = BehaviorRelay<[Actor]>(value: [])
    
    // MARK: - Outlets
    @IBOutlet weak var castCollectionView: UICollectionView! {
        didSet {
            castCollectionView.letIt {
                $0.delegate = self
                $0.register(nibType: CastCollectionViewCell.self)
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupNavigationBar(title: "Cast")
        castRelay
            .asDriver()
            .drive(castCollectionView.rx.items) { collectionView, index, element in
                let indexPath = IndexPath(row: index, section: 0)
                let cell = collectionView.dequeueReusableCell(with: CastCollectionViewCell.self, for: indexPath)
                cell.updateDataOfCell(actorName: element.name, imageUrl: element.avatar)
                return cell
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Cast Collection View Delegate Flow Layout
extension CastViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = (collectionView.frame.width - Constant.edgePadding * 3) / 2
        return CGSize(width: width, height: width + 40)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constant.edgePadding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == castCollectionView {
            return UIEdgeInsets(top: 0, left: Constant.edgePadding, bottom: Constant.edgePadding, right: Constant.edgePadding)
        }
        return UIEdgeInsets.zero
    }
}

