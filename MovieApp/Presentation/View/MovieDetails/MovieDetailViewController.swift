import UIKit
import Kingfisher
import AVKit
import AVFoundation

class MovieDetailViewController: BaseViewController {
    // MARK: - Variables
    var movie: Movie! {
        didSet {
            viewModel.loadComments(movieId: movie.id)
        }
    }
    private var comments: [Comment] = []
    private let categoryCellNibName = String(describing: CategoryCollectionViewCell.self)
    private let castCellNibName = String(describing: CastCollectionViewCell.self)
    private let viewModel = MovieDetailViewModel()
    private let commentsCellNibName = String(describing: CommentsTableViewCell.self)
    private lazy var videoPlayer : VideoPlayer = .fromNib()
    private lazy var castCellWidth = (castCollectionView.frame.width - Constant.edgePadding * 2 - Constant.lineSpacing * 3) / 4
    private lazy var castCellHeight = castCellWidth + 40
    
    // MARK: - Outlets
    @IBOutlet private(set) weak var commentTextField: AutoChangePositionTextField!
    @IBOutlet private(set) weak var commentsTableViewHeight: NSLayoutConstraint!
    @IBOutlet private(set) weak var castCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet private(set) weak var commentsTableView: UITableView!
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
    @IBOutlet private(set) weak var categoryColectionView: UICollectionView!
    @IBOutlet private(set) weak var movieBodyView: UIView!
    @IBOutlet private(set) weak var movieImageView: UIImageView!
    @IBOutlet private(set) weak var categoryColectionViewHeight: NSLayoutConstraint!
    @IBOutlet private(set) weak var castCollectionView: UICollectionView!
    
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
        viewModel.loadingState.observe(on: self) { [weak self] in self?.updateLoadingState($0) }
        viewModel.error.observe(on: self) { [weak self] in self?.showError($0) }
        viewModel.comments.observe(on: self) { [weak self] in self?.updateComments($0) }
        viewModel.load()
    }
    
    func updateComments(_ comments: [Comment]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.comments = comments
            commentsTableView.reloadData()
            commentsTableViewHeight.constant = commentsTableView.contentSize.height
            viewDidLayoutSubviews()
        }
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
        setupCollectionView()
        setupTableView()
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
    
    private func setupTableView() {
        commentsTableView.dataSource = self
        commentsTableView.delegate = self
        
        commentsTableView.estimatedRowHeight = Constant.commentsTableViewCellHeight
        commentsTableView.rowHeight = UITableView.automaticDimension
        let nib = UINib(nibName: commentsCellNibName, bundle: nil)
        commentsTableView.register(nib, forCellReuseIdentifier: commentsCellNibName)
    }
    
    private func setupCollectionView() {
        categoryColectionView.dataSource = self
        categoryColectionView.delegate = self
        castCollectionView.dataSource = self
        castCollectionView.delegate = self
        
        let layout = TagFlowLayout()
        categoryColectionView.collectionViewLayout = layout
        let categoryCellNib = UINib(nibName: categoryCellNibName, bundle: nil)
        categoryColectionView.register(categoryCellNib, forCellWithReuseIdentifier: categoryCellNibName)
        let castCellNib = UINib(nibName: castCellNibName, bundle: nil)
        castCollectionView.register(castCellNib, forCellWithReuseIdentifier: castCellNibName)
    }
    
    private func customOutlets() {
        self.seeMoreCastButton.applyCustomStyle(style: .outline)
        self.seeMoreCommentsButton.applyCustomStyle(style: .outline)
        bookmarkButton.isSelected = viewModel.isMovieInWatchList(movieId: movie.id)
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
        viewModel.checkLoggedIn() { [weak self] in
            guard let self  = self else { return }
            guard let url = URL(string: self.movie.videoLink) else {return}
            setupVideoPlayerView()
            videoPlayer.isToShowPlaybackControls = true
            videoPlayer.loadVideo(with: url)
            videoPlayer.isMuted = false
            videoPlayer.playVideo()
        }
    }
    
    @IBAction func commentTextFieldDidEndOnExit(_ sender: Any) {
        viewModel.checkLoggedIn() { [weak self] in
            guard let self  = self else { return }
            guard let content  = commentTextField.text?.trim(), !content.isEmpty else { return }
            commentTextField.text = ""
            viewModel.addComment(movieId: movie.id, content: content)
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
        viewModel.toggleSaveToWatchList(movieId: movie.id, action: bookmarkButton.isSelected ? .remove : .add) { [weak self] in
            guard let self = self else { return }
            bookmarkButton.isSelected.toggle()
        }
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
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellNibName, for: indexPath) as? CategoryCollectionViewCell
            {
                cell.categoryLabel.text = self.movie.categories[indexPath.row].uppercased()
                return cell
            }
        } else if collectionView == castCollectionView{
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: castCellNibName, for: indexPath) as? CastCollectionViewCell
            {
                let cast = self.movie.cast[indexPath.row]
                cell.updateDataOfCell(actorName: cast.name , imageUrl: cast.avatar)
                return cell
            }
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

// MARK: - Movie Details Table Data Source
extension MovieDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: commentsCellNibName, for: indexPath) as? CommentsTableViewCell else { return UITableViewCell()}
        let comment = comments[indexPath.row]
        cell.usernameLabel.text = comment.user.username
        cell.commentLabel.text = comment.content
        cell.avatarImageView.kf.setImage(with: URL(string: comment.user.avatar))
        return cell
    }
}

