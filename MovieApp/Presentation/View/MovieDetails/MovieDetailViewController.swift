import UIKit
import Kingfisher
import AVKit
import AVFoundation
import RxSwift
import RxCocoa

class MovieDetailViewController: BaseViewController {
    // MARK: - Variables
    var movie: Movie!
    private var comments: [Comment] = []
    private let viewModel = MovieDetailViewModel()
    private lazy var videoPlayer : VideoPlayer = .fromNib()
    private lazy var castCellWidth = (castCollectionView.frame.width - Constant.edgePadding * 2 - Constant.lineSpacing * 3) / 4
    private lazy var castCellHeight = castCellWidth + 40
    private var checkLoggedInTriger = PublishRelay<Void>()
    private var loadCommentsTrigger = PublishRelay<String>()
    private var addCommentsTrigger = PublishRelay<(movieId: String, content: String)>()
    private var toggleSaveToWatchListTriger = PublishRelay<(String, MovieDetailViewModel.WatchListAction)>()
    private var isLoggedIn = BehaviorRelay<Bool>(value: false)
    private var isMovieInWatchList = false
    
    // MARK: - Outlets
    @IBOutlet private(set) weak var commentTextField: AutoChangePositionTextField!
    @IBOutlet private(set) weak var commentsTableViewHeight: NSLayoutConstraint!
    @IBOutlet private(set) weak var castCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet private(set) weak var bookmarkButton: UIButton!
    @IBOutlet private(set) weak var headerMaskView: UIView!
    @IBOutlet private(set) weak var videoPlayBackView: UIView!
    @IBOutlet private(set) weak var descriptionLabel: UILabel!
    @IBOutlet private(set) weak var contentRatingLabel: UILabel!
    @IBOutlet private(set) weak var languageLabel: UILabel!
    @IBOutlet private(set) weak var durationLabel: UILabel!
    @IBOutlet private(set) weak var ratingLabel: UILabel!
    @IBOutlet private(set) weak var movieNameLabel: UILabel!
    @IBOutlet private(set) weak var seeMoreCommentsButton: UIButton!
    @IBOutlet private(set) weak var seeMoreCastButton: UIButton!
    @IBOutlet private(set) weak var movieBodyView: UIView!
    @IBOutlet private(set) weak var movieImageView: UIImageView!
    @IBOutlet private(set) weak var categoryColectionViewHeight: NSLayoutConstraint!
    @IBOutlet private(set) weak var commentsTableView: UITableView! {
        didSet {
            commentsTableView.letIt {
                $0.estimatedRowHeight = Constant.commentsTableViewCellHeight
                $0.rowHeight = UITableView.automaticDimension
                $0.register(nibType: CommentsTableViewCell.self)
            }
        }
    }
    @IBOutlet private(set) weak var castCollectionView: UICollectionView! {
        didSet {
            castCollectionView.letIt {
                $0.delegate = self
                $0.dataSource = self
                $0.register(nibType: CastCollectionViewCell.self)
            }
        }
    }
    @IBOutlet private(set) weak var categoryColectionView: UICollectionView! {
        didSet {
            categoryColectionView.letIt {
                $0.delegate = self
                $0.dataSource = self
                $0.register(nibType: CategoryCollectionViewCell.self)
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindingViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
        self.setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(.transparentWithBackAndMenuButton)
        self.tabBarController?.tabBar.isHidden  = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Binding View Model
    private func bindingViewModel(){
        
        let input = MovieDetailViewModel.Input(
            checLoggedIn: checkLoggedInTriger.asDriverOnErrorJustComplete(),
            toggleSaveToWatchList: toggleSaveToWatchListTriger.asDriverOnErrorJustComplete(),
            checkMovieContainInWatchList: .just(movie.id),
            loadCommentsTrigger: loadCommentsTrigger.asDriverOnErrorJustComplete(),
            addCommentsTrigger: addCommentsTrigger.asDriverOnErrorJustComplete()
        )
        
        let output = viewModel.transform(input: input)
        output.loadingState
            .drive{ [weak self] in self?.updateLoadingState($0) }.disposed(by: disposeBag)
        output.error
            .drive{ [weak self] in self?.showError($0) }.disposed(by: disposeBag)
        output.isLoggedIn
            .drive(isLoggedIn).disposed(by: disposeBag)
        output.isMovieInWatchList
            .drive{ [weak self] in
            self?.isMovieInWatchList = $0
            self?.bookmarkButton.isSelected = $0
        }.disposed(by: disposeBag)
        output.toggleSaveToWatchListCompletion
            .drive { [weak self] action in
            self?.bookmarkButton.isSelected.toggle()
        }.disposed(by: disposeBag)
        
        output.comments
            .drive(commentsTableView.rx.items) { tableView, index, element in
                let indexPath = IndexPath(row: index, section: 0)
                let cell = tableView.dequeueReusableCell(with: CommentsTableViewCell.self, for: indexPath)
                cell.usernameLabel.text = element.user.username
                cell.commentLabel.text = element.content
                cell.avatarImageView.kf.setImage(with: URL(string: element.user.avatar))
                return cell
            }
            .disposed(by: disposeBag)
        commentsTableView.rx.bindContentHeight(to: commentsTableViewHeight).disposed(by: disposeBag)
        loadCommentsTrigger.accept(movie.id)
    }

    // MARK: - UI Setup
    private func setupLayout(){
        self.movieBodyView.roundCorners(corners: [.topLeft, .topRight], radius: 14)
        self.categoryColectionViewHeight.constant = categoryColectionView.collectionViewLayout.collectionViewContentSize.height
        commentsTableViewHeight.constant = commentsTableView.contentSize.height
        if movie.cast.count == 0 {
            castCollectionViewHeight.constant = 0
        }
        else {
            castCollectionViewHeight.constant = castCellHeight
        }
        
    }
    
    private func setupUI() {
        customOutlets()
        updateViewComponentData()
    }
    
    private func updateViewComponentData() {
        movieNameLabel.text = movie.name
        ratingLabel.text = movie.rating
        durationLabel.text = movie.duration
        languageLabel.text = movie.language
        contentRatingLabel.text = movie.contentRating
        descriptionLabel.text = movie.description
    }
    
    private func customOutlets() {
        self.seeMoreCastButton.applyCustomStyle(style: .outline)
        self.seeMoreCommentsButton.applyCustomStyle(style: .outline)
        bookmarkButton.isSelected = isMovieInWatchList
        if !(movie?.imageUrl ?? "").isEmpty{
            let imageUrl = URL(string: movie?.imageUrl ?? "")
            self.movieImageView.kf.setImage(with: imageUrl)
        }
    }
    
    
    private func setupVideoPlayerView() {
        self.headerMaskView.backgroundColor = .systemBackground
        self.videoPlayBackView.superview?.bringSubviewToFront(self.videoPlayBackView)
        videoPlayer.frame = videoPlayBackView.bounds
        videoPlayer.isToShowPlaybackControls = true
        self.videoPlayBackView.addSubview(videoPlayer)
    }
    
    // MARK: - Actions
    @IBAction func playBackButtonTapped(_ sender: Any) {
        checkLoggedInTriger.accept(())
        if isLoggedIn.value {
            guard let url = URL(string: self.movie.videoLink) else {return}
            setupVideoPlayerView()
            videoPlayer.isToShowPlaybackControls = true
            videoPlayer.loadVideo(with: url)
            videoPlayer.isMuted = false
            videoPlayer.playVideo()
        }
    }
    
    @IBAction func commentTextFieldDidEndOnExit(_ sender: Any) {
        checkLoggedInTriger.accept(())
        if isLoggedIn.value {
            guard let content  = commentTextField.text?.trim(), !content.isEmpty else { return }
            commentTextField.text = ""
            addCommentsTrigger.accept((movie.id, content))
        }
    }
    
    @IBAction func seemoreCommentsButtonTouchUpInside(_ sender: Any) {
        let vc = AllCommentsViewController()
        vc.movieId = movie.id
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func seeMoreCastButtonTouchUpInside(_ sender: Any) {
        let vc = CastViewController()
        vc.cast = movie.cast
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func bookmarkButtonTouchUpInside(_ sender: Any) {
        toggleSaveToWatchListTriger.accept((movie.id, bookmarkButton.isSelected ? .remove : .add))
    }
    
}

// MARK: - Movie Details Collection View Data Source
extension MovieDetailViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryColectionView{
            return self.movie.categories.count
        } else if collectionView == castCollectionView{
            return movie.cast.count > 4 ? 4 : movie.cast.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryColectionView{
            let cell = collectionView.dequeueReusableCell(with: CategoryCollectionViewCell.self, for: indexPath)
            cell.categoryLabel.text = self.movie.categories[indexPath.row].uppercased()
            return cell
        } else if collectionView == castCollectionView{
            let cell = collectionView.dequeueReusableCell(with: CastCollectionViewCell.self, for: indexPath)
            let cast = self.movie.cast[indexPath.row]
            cell.updateDataOfCell(actorName: cast.name , imageUrl: cast.avatar)
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: - Movie Details Collection View Delegate Flow Layout
extension MovieDetailViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == categoryColectionView{
            let title = self.movie.categories[indexPath.row]
            let paddingHorizontal = 12.0
            let width = title.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 8, weight: .bold)]).width + paddingHorizontal * 2 + 12
            return CGSize(width: width, height: 20)
        } else if collectionView == castCollectionView{
            return CGSize(width: castCellWidth, height: castCellHeight)
        }
        return CGSize.zero
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constant.lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == castCollectionView{
            return UIEdgeInsets(top: 0, left: Constant.edgePadding, bottom: 0, right: Constant.edgePadding)
        }
        return UIEdgeInsets.zero
    }
}

// MARK: - Movie Details Table View Delegate
extension MovieDetailViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

