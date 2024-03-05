import UIKit

class CastViewController: BaseViewController {
    // MARK: - Variables
    var cast: [Actor]!
    private let castCellNibName = String(describing: CastCollectionViewCell.self)
    
    // MARK: - Outlets
    @IBOutlet weak var castCollectionView: UICollectionView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupCollectionView()
        setupNavigationBar(title: "Cast")
    }
    
    private func setupCollectionView() {
        self.castCollectionView.dataSource = self
        self.castCollectionView.delegate = self
        let castCellNib = UINib(nibName: castCellNibName, bundle: nil)
        self.castCollectionView.register(castCellNib, forCellWithReuseIdentifier: castCellNibName)
    }
}

extension CastViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: castCellNibName, for: indexPath) as? CastCollectionViewCell
        {
            let actor = cast[indexPath.row]
            cell.updateDataOfCell(actorName: actor.name, imageUrl: actor.avatar)
            return cell
        }
        return UICollectionViewCell()
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

